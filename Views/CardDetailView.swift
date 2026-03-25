//
//  CardDetailView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import SwiftUI
import SwiftData

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let card: CreditCard

    @State private var showEditSheet = false
    @State private var showDeleteDialog = false
    @State private var feeReminderEnabled: Bool
    @State private var feeReminderDate: Date
    @State private var paymentReminderEnabled: Bool
    @State private var paymentReminderDate: Date


    init(card: CreditCard) {
        self.card = card
        _feeReminderEnabled = State(initialValue: card.feeReminderEnabled)
        _feeReminderDate = State(initialValue: card.feeRenewalDate ?? .now)
        _paymentReminderEnabled = State(initialValue: card.paymentReminderEnabled)
        _paymentReminderDate = State(initialValue: Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: .now), month: Calendar.current.component(.month, from: .now), day: card.paymentDueDay ?? 1)) ?? .now)
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                CreditCardVisualView(card: card)

                strongestCategoriesSection

                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("基础信息")
                            .font(.headline)

                        detailRow("卡片名称", card.name)
                        detailRow("卡组织", card.network.title)
                        detailRow("发卡银行", card.issuerBank)
                        detailRow("卡号后四位", card.last4Digits)
                        detailRow("Reward 类型", card.rewardType.title)
                        detailRow("费用类型", card.feeType.title)
                        detailRow("费用", card.feeText)
                        detailRow("外币手续费", card.foreignTransactionFeeText)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("回报倍率")
                            .font(.headline)

                        LazyVGrid(columns: columns, spacing: 12) {
                            rewardItem(title: "餐饮", value: card.rewardDining)
                            rewardItem(title: "超市", value: card.rewardGroceries)
                            rewardItem(title: "交通", value: card.rewardTransit)
                            rewardItem(title: "加油", value: card.rewardGas)
                            rewardItem(title: "旅行", value: card.rewardTravel)
                            rewardItem(title: "购物", value: card.rewardShopping)
                            rewardItem(title: "账单", value: card.rewardBills)
                        }
                    }
                }

                if !card.benefitName.isEmpty || card.benefitExpiryDate != nil {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("福利信息")
                                .font(.headline)

                            detailRow("福利名称", card.benefitName.isEmpty ? "未设置" : card.benefitName)

                            if let benefitExpiryDate = card.benefitExpiryDate {
                                detailRow(
                                    "福利过期日期",
                                    benefitExpiryDate.formatted(date: .abbreviated, time: .omitted)
                                )
                            }
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("提醒设置")
                            .font(.headline)

                        Toggle("年/月费提醒", isOn: $feeReminderEnabled)
                        if feeReminderEnabled {
                            DatePicker("提醒日期", selection: $feeReminderDate, displayedComponents: .date)
                        }

                        Toggle("还款日提醒", isOn: $paymentReminderEnabled)
                        if paymentReminderEnabled {
                            DatePicker("提醒日期", selection: $paymentReminderDate, displayedComponents: .date)
                        }

                        Button("保存提醒设置") {
                            saveReminderSettings()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }

                Button(role: .destructive) {
                    showDeleteDialog = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditCardView(card: card)
        }
        .confirmationDialog(
            "删除这张信用卡？",
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            Button("删除", role: .destructive) {
                deleteCard()
            }

            Button("取消", role: .cancel) { }
        } message: {
            Text("删除后会同时移除该卡片的提醒通知。")
        }
    }

    private var strongestCategoriesSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("最强类别")
                    .font(.headline)

                Text("根据当前卡片的 Reward 类型，以下是这张卡回报最强的 3 个消费类别。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(topRewardRows, id: \.id) { row in
                    HStack {
                        Label(row.title, systemImage: row.systemImage)
                        Spacer()
                        Text(formattedRewardValue(row.value))
                            .font(.headline)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private var topRewardRows: [RewardRow] {
        var rows = RewardCategory.allCases.map {
            RewardRow(id: $0.rawValue, title: $0.title, systemImage: $0.systemImage, value: card.reward(for: $0))
        }
        rows += RewardCategoryStore.all().filter { !$0.isBuiltIn }.map {
            RewardRow(id: $0.id, title: $0.title, systemImage: $0.systemImage, value: card.rewardValue(for: $0.id))
        }
        return Array(rows.sorted { $0.value > $1.value }.prefix(3))
    }

    private func formattedRewardValue(_ value: Double) -> String {
        switch card.rewardType {
        case .cashBack:
            return String(format: "%.1f%%", value)
        case .pointsReward:
            return String(format: "%.1fX", value)
        }
    }

    private var feeReminderDescription: String {
        guard card.feeReminderEnabled else { return "未开启" }

        switch card.feeType {
        case .annual:
            if let feeRenewalDate = card.feeRenewalDate {
                return "续费日期：\(feeRenewalDate.formatted(date: .abbreviated, time: .omitted))，提前 \(card.feeReminderLeadDays) 天提醒"
            } else {
                return "已开启，但未设置续费日期"
            }

        case .monthly:
            if let feeBillingDay = card.feeBillingDay {
                return "每月 \(feeBillingDay) 日扣费，提前 \(card.feeReminderLeadDays) 天提醒"
            } else {
                return "已开启，但未设置每月扣费日"
            }
        }
    }

    private var benefitReminderDescription: String {
        guard card.benefitReminderEnabled else { return "未开启" }

        if let benefitExpiryDate = card.benefitExpiryDate {
            return "福利到期日：\(benefitExpiryDate.formatted(date: .abbreviated, time: .omitted))，提前 \(card.benefitReminderLeadDays) 天提醒"
        } else {
            return "已开启，但未设置福利过期日期"
        }
    }

    private var paymentReminderDescription: String {
        guard card.paymentReminderEnabled else { return "未开启" }

        if let paymentDueDay = card.paymentDueDay {
            return "每月 \(paymentDueDay) 日还款，提前 \(card.paymentReminderLeadDays) 天提醒"
        } else {
            return "已开启，但未设置每月还款日"
        }
    }

    private var monthlyReviewDescription: String {
        guard card.monthlyReviewReminderEnabled else { return "未开启" }

        if let monthlyReviewDay = card.monthlyReviewDay {
            return "每月 \(monthlyReviewDay) 日检查，提前 \(card.monthlyReviewLeadDays) 天提醒"
        } else {
            return "已开启，但未设置每月检查日"
        }
    }

    @ViewBuilder
    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    @ViewBuilder
    private func rewardItem(title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(formattedRewardValue(value))
                .font(.headline)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    @ViewBuilder
    private func reminderItem(title: String, enabled: Bool, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)

                Spacer()

                Text(enabled ? "已开启" : "未开启")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        enabled ? Color.green.opacity(0.16) : Color.gray.opacity(0.16),
                        in: Capsule()
                    )
            }

            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }


    private func saveReminderSettings() {
        card.feeReminderEnabled = feeReminderEnabled
        card.feeRenewalDate = feeReminderEnabled ? feeReminderDate : nil
        card.paymentReminderEnabled = paymentReminderEnabled
        card.paymentDueDay = paymentReminderEnabled ? Calendar.current.component(.day, from: paymentReminderDate) : nil

        try? modelContext.save()

        Task {
            if feeReminderEnabled || paymentReminderEnabled {
                let granted = await NotificationManager.shared.requestAuthorization()
                if granted { await NotificationManager.shared.refreshNotifications(for: card) }
            } else {
                NotificationManager.shared.removeNotifications(for: card.id)
            }
        }
    }

    private func deleteCard() {
        NotificationManager.shared.removeNotifications(for: card.id)
        modelContext.delete(card)

        do {
            try modelContext.save()
        } catch {
            print("删除卡片失败: \(error)")
        }

        dismiss()
    }
}


private struct RewardRow: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let value: Double
}
