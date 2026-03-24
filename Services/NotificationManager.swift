//
//  NotificationManager.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - Public

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("通知授权失败: \(error)")
            return false
        }
    }

    func refreshNotifications(for card: CreditCard) async {
        removeNotifications(for: card.id)

        await scheduleFeeReminder(for: card)
        await scheduleBenefitReminder(for: card)
        await schedulePaymentReminder(for: card)
        await scheduleMonthlyReviewReminder(for: card)
    }

    func removeNotifications(for cardID: UUID) {
        let identifiers = [
            feeReminderIdentifier(for: cardID),
            benefitReminderIdentifier(for: cardID),
            paymentReminderIdentifier(for: cardID),
            monthlyReviewReminderIdentifier(for: cardID)
        ]

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    // MARK: - Identifier Helpers

    private func feeReminderIdentifier(for cardID: UUID) -> String {
        "fee_reminder_\(cardID.uuidString)"
    }

    private func benefitReminderIdentifier(for cardID: UUID) -> String {
        "benefit_reminder_\(cardID.uuidString)"
    }

    private func paymentReminderIdentifier(for cardID: UUID) -> String {
        "payment_reminder_\(cardID.uuidString)"
    }

    private func monthlyReviewReminderIdentifier(for cardID: UUID) -> String {
        "monthly_review_reminder_\(cardID.uuidString)"
    }

    // MARK: - Scheduling

    private func scheduleFeeReminder(for card: CreditCard) async {
        guard card.feeReminderEnabled else { return }

        let reminderDate: Date?

        switch card.feeType {
        case .annual:
            guard let renewalDate = card.feeRenewalDate else { return }
            reminderDate = nextAnnualReminderDate(
                baseDate: renewalDate,
                leadDays: card.feeReminderLeadDays
            )

        case .monthly:
            guard let billingDay = card.feeBillingDay else { return }
            reminderDate = nextMonthlyReminderDate(
                dueDay: billingDay,
                leadDays: card.feeReminderLeadDays
            )
        }

        guard let triggerDate = reminderDate else { return }

        let content = UNMutableNotificationContent()
        content.title = card.feeType == .annual ? "年费提醒" : "月费提醒"
        content.body = "\(card.name) 即将产生\(card.feeType == .annual ? "年费" : "月费")，记得检查是否继续持有。"
        content.sound = .default

        await scheduleNotification(
            identifier: feeReminderIdentifier(for: card.id),
            content: content,
            triggerDate: triggerDate
        )
    }

    private func scheduleBenefitReminder(for card: CreditCard) async {
        guard card.benefitReminderEnabled else { return }
        guard let expiryDate = card.benefitExpiryDate else { return }

        let reminderDate = Calendar.current.date(
            byAdding: .day,
            value: -max(card.benefitReminderLeadDays, 0),
            to: setToNineAM(expiryDate)
        ) ?? expiryDate

        guard reminderDate > .now else { return }

        let benefitLabel = card.benefitName.isEmpty ? "信用卡福利" : card.benefitName

        let content = UNMutableNotificationContent()
        content.title = "福利过期提醒"
        content.body = "\(card.name) 的「\(benefitLabel)」即将过期，别忘了使用。"
        content.sound = .default

        await scheduleNotification(
            identifier: benefitReminderIdentifier(for: card.id),
            content: content,
            triggerDate: reminderDate
        )
    }

    private func schedulePaymentReminder(for card: CreditCard) async {
        guard card.paymentReminderEnabled else { return }
        guard let paymentDueDay = card.paymentDueDay else { return }

        guard let reminderDate = nextMonthlyReminderDate(
            dueDay: paymentDueDay,
            leadDays: card.paymentReminderLeadDays
        ) else { return }

        let content = UNMutableNotificationContent()
        content.title = "还款日提醒"
        content.body = "\(card.name) 即将到达还款日，记得按时还款。"
        content.sound = .default

        await scheduleNotification(
            identifier: paymentReminderIdentifier(for: card.id),
            content: content,
            triggerDate: reminderDate
        )
    }

    private func scheduleMonthlyReviewReminder(for card: CreditCard) async {
        guard card.monthlyReviewReminderEnabled else { return }
        guard let reviewDay = card.monthlyReviewDay else { return }

        guard let reminderDate = nextMonthlyReminderDate(
            dueDay: reviewDay,
            leadDays: card.monthlyReviewLeadDays
        ) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Reward 检查提醒"
        content.body = "记得检查一下 \(card.name) 的 reward 类别是否有变化。"
        content.sound = .default

        await scheduleNotification(
            identifier: monthlyReviewReminderIdentifier(for: card.id),
            content: content,
            triggerDate: reminderDate
        )
    }

    // MARK: - Core Scheduling

    private func scheduleNotification(
        identifier: String,
        content: UNNotificationContent,
        triggerDate: Date
    ) async {
        guard triggerDate > .now else { return }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("添加通知失败（\(identifier)）: \(error)")
        }
    }

    // MARK: - Date Helpers

    private func nextAnnualReminderDate(baseDate: Date, leadDays: Int) -> Date? {
        let calendar = Calendar.current
        let reference = Date()

        let baseComponents = calendar.dateComponents([.month, .day], from: baseDate)
        guard let month = baseComponents.month,
              let day = baseComponents.day else {
            return nil
        }

        let currentYear = calendar.component(.year, from: reference)

        for yearOffset in 0...5 {
            let targetYear = currentYear + yearOffset

            var components = DateComponents()
            components.year = targetYear
            components.month = month

            let monthAnchor = calendar.date(from: DateComponents(year: targetYear, month: month)) ?? reference
            let validDayRange = calendar.range(of: .day, in: .month, for: monthAnchor) ?? (1..<29)
            let maxValidDay = validDayRange.upperBound - 1

            components.day = min(day, maxValidDay)
            components.hour = 9
            components.minute = 0

            if let dueDate = calendar.date(from: components) {
                let reminderDate = calendar.date(
                    byAdding: .day,
                    value: -max(leadDays, 0),
                    to: dueDate
                ) ?? dueDate

                if reminderDate > reference {
                    return reminderDate
                }
            }
        }

        return nil
    }

    private func nextMonthlyReminderDate(dueDay: Int, leadDays: Int) -> Date? {
        let calendar = Calendar.current
        let reference = Date()

        for monthOffset in 0...14 {
            guard let monthBase = calendar.date(byAdding: .month, value: monthOffset, to: reference) else {
                continue
            }

            let dayRange = calendar.range(of: .day, in: .month, for: monthBase) ?? (1..<29)
            let maxValidDay = dayRange.upperBound - 1
            let clampedDay = min(max(dueDay, 1), maxValidDay)

            var components = calendar.dateComponents([.year, .month], from: monthBase)
            components.day = clampedDay
            components.hour = 9
            components.minute = 0

            if let dueDate = calendar.date(from: components) {
                let reminderDate = calendar.date(
                    byAdding: .day,
                    value: -max(leadDays, 0),
                    to: dueDate
                ) ?? dueDate

                if reminderDate > reference {
                    return reminderDate
                }
            }
        }

        return nil
    }

    private func setToNineAM(_ date: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? date
    }
}
