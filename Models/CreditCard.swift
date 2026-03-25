//
//  CreditCard.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import Foundation
import SwiftData

@Model
final class CreditCard: Identifiable {
    var id: UUID
    var name: String

    var networkRawValue: String
    var issuerBank: String

    var last4Digits: String

    var feeTypeRawValue: String
    var feeAmount: Double
    var feeEnabled: Bool

    var foreignTransactionFee: Double
    var foreignTransactionFeeEnabled: Bool
    var rewardTypeRawValue: String

    var themeName: String
    var customCardImageData: Data?

    var createdAt: Date
    var isArchived: Bool

    // 固定类别
    var rewardDining: Double
    var rewardGroceries: Double
    var rewardTransit: Double
    var rewardGas: Double
    var rewardTravel: Double
    var rewardShopping: Double
    var rewardBills: Double

    // 可扩展类别（JSON）
    var customRewardsData: String

    // Welcome Bonus
    var welcomeBonusEnabled: Bool
    var welcomeBonusExpiryDate: Date?
    var welcomeBonusSpendAmount: Double
    var welcomeBonusCycleRawValue: String
    var welcomeBonusValue: Double

    // Offer
    var offersEnabled: Bool
    var offersData: String

    // 兼容旧字段
    var benefitName: String
    var benefitExpiryDate: Date?

    // 提醒
    var feeReminderEnabled: Bool
    var feeReminderLeadDays: Int
    var feeRenewalDate: Date?
    var feeBillingDay: Int?

    var benefitReminderEnabled: Bool
    var benefitReminderLeadDays: Int

    var paymentReminderEnabled: Bool
    var paymentReminderLeadDays: Int
    var paymentDueDay: Int?

    var monthlyReviewReminderEnabled: Bool
    var monthlyReviewLeadDays: Int
    var monthlyReviewDay: Int?

    init(
        id: UUID = UUID(),
        name: String,
        network: CardNetwork = .visa,
        issuerBank: String,
        last4Digits: String,
        feeType: FeeType = .annual,
        feeAmount: Double,
        feeEnabled: Bool = true,
        foreignTransactionFee: Double = 0,
        foreignTransactionFeeEnabled: Bool = true,
        rewardType: RewardType = .cashBack,
        themeName: String = "ocean",
        customCardImageData: Data? = nil,
        createdAt: Date = .now,
        isArchived: Bool = false,
        rewardDining: Double = 1,
        rewardGroceries: Double = 1,
        rewardTransit: Double = 1,
        rewardGas: Double = 1,
        rewardTravel: Double = 1,
        rewardShopping: Double = 1,
        rewardBills: Double = 1,
        customRewardsData: String = "{}",
        welcomeBonusEnabled: Bool = false,
        welcomeBonusExpiryDate: Date? = nil,
        welcomeBonusSpendAmount: Double = 0,
        welcomeBonusCycle: WelcomeBonusCycle = .monthly,
        welcomeBonusValue: Double = 0,
        offersEnabled: Bool = false,
        offersData: String = "[]",
        benefitName: String = "",
        benefitExpiryDate: Date? = nil,
        feeReminderEnabled: Bool = false,
        feeReminderLeadDays: Int = 30,
        feeRenewalDate: Date? = nil,
        feeBillingDay: Int? = nil,
        benefitReminderEnabled: Bool = false,
        benefitReminderLeadDays: Int = 14,
        paymentReminderEnabled: Bool = false,
        paymentReminderLeadDays: Int = 3,
        paymentDueDay: Int? = nil,
        monthlyReviewReminderEnabled: Bool = false,
        monthlyReviewLeadDays: Int = 0,
        monthlyReviewDay: Int? = 1
    ) {
        self.id = id
        self.name = name
        self.networkRawValue = network.rawValue
        self.issuerBank = issuerBank
        self.last4Digits = last4Digits
        self.feeTypeRawValue = feeType.rawValue
        self.feeAmount = feeAmount
        self.feeEnabled = feeEnabled
        self.foreignTransactionFee = foreignTransactionFee
        self.foreignTransactionFeeEnabled = foreignTransactionFeeEnabled
        self.rewardTypeRawValue = rewardType.rawValue
        self.themeName = themeName
        self.customCardImageData = customCardImageData
        self.createdAt = createdAt
        self.isArchived = isArchived
        self.rewardDining = rewardDining
        self.rewardGroceries = rewardGroceries
        self.rewardTransit = rewardTransit
        self.rewardGas = rewardGas
        self.rewardTravel = rewardTravel
        self.rewardShopping = rewardShopping
        self.rewardBills = rewardBills
        self.customRewardsData = customRewardsData
        self.welcomeBonusEnabled = welcomeBonusEnabled
        self.welcomeBonusExpiryDate = welcomeBonusExpiryDate
        self.welcomeBonusSpendAmount = welcomeBonusSpendAmount
        self.welcomeBonusCycleRawValue = welcomeBonusCycle.rawValue
        self.welcomeBonusValue = welcomeBonusValue
        self.offersEnabled = offersEnabled
        self.offersData = offersData
        self.benefitName = benefitName
        self.benefitExpiryDate = benefitExpiryDate
        self.feeReminderEnabled = feeReminderEnabled
        self.feeReminderLeadDays = feeReminderLeadDays
        self.feeRenewalDate = feeRenewalDate
        self.feeBillingDay = feeBillingDay
        self.benefitReminderEnabled = benefitReminderEnabled
        self.benefitReminderLeadDays = benefitReminderLeadDays
        self.paymentReminderEnabled = paymentReminderEnabled
        self.paymentReminderLeadDays = paymentReminderLeadDays
        self.paymentDueDay = paymentDueDay
        self.monthlyReviewReminderEnabled = monthlyReviewReminderEnabled
        self.monthlyReviewLeadDays = monthlyReviewLeadDays
        self.monthlyReviewDay = monthlyReviewDay
    }

    var network: CardNetwork {
        get { CardNetwork(rawValue: networkRawValue) ?? .visa }
        set { networkRawValue = newValue.rawValue }
    }

    var feeType: FeeType {
        get { FeeType(rawValue: feeTypeRawValue) ?? .annual }
        set { feeTypeRawValue = newValue.rawValue }
    }

    var rewardType: RewardType {
        get { RewardType(rawValue: rewardTypeRawValue) ?? .cashBack }
        set { rewardTypeRawValue = newValue.rawValue }
    }

    var welcomeBonusCycle: WelcomeBonusCycle {
        get { WelcomeBonusCycle(rawValue: welcomeBonusCycleRawValue) ?? .monthly }
        set { welcomeBonusCycleRawValue = newValue.rawValue }
    }

    var issuer: String {
        get { issuerBank }
        set { issuerBank = newValue }
    }

    var annualFee: Double {
        get { feeAmount }
        set { feeAmount = newValue }
    }

    var annualFeeRenewalDate: Date? {
        get { feeRenewalDate }
        set { feeRenewalDate = newValue }
    }

    var notificationAnnualFeeEnabled: Bool {
        get { feeReminderEnabled }
        set { feeReminderEnabled = newValue }
    }

    var notificationBenefitEnabled: Bool {
        get { benefitReminderEnabled }
        set { benefitReminderEnabled = newValue }
    }

    var notificationMonthlyReviewEnabled: Bool {
        get { monthlyReviewReminderEnabled }
        set { monthlyReviewReminderEnabled = newValue }
    }

    var maskedNumber: String { "•••• \(last4Digits)" }

    var feeText: String {
        guard feeEnabled else { return feeType == .annual ? "无年费" : "无月费" }
        let suffix = feeType == .annual ? "/年" : "/月"
        if feeAmount == 0 {
            return feeType == .annual ? "无年费" : "$0/月"
        }
        return String(format: "$%.2f%@", feeAmount, suffix)
    }

    var annualFeeText: String { feeText }

    var foreignTransactionFeeText: String {
        guard foreignTransactionFeeEnabled else { return "未设置" }
        return String(format: "%.2f%%", foreignTransactionFee)
    }

    func reward(for category: RewardCategory) -> Double {
        switch category {
        case .dining: return rewardDining
        case .groceries: return rewardGroceries
        case .transit: return rewardTransit
        case .gas: return rewardGas
        case .travel: return rewardTravel
        case .shopping: return rewardShopping
        case .bills: return rewardBills
        }
    }

    var customRewardMap: [String: Double] {
        get { (try? JSONDecoder().decode([String: Double].self, from: Data(customRewardsData.utf8))) ?? [:] }
        set {
            if let data = try? JSONEncoder().encode(newValue), let text = String(data: data, encoding: .utf8) {
                customRewardsData = text
            }
        }
    }

    func rewardValue(for categoryID: String) -> Double {
        if let fixed = RewardCategory(rawValue: categoryID) {
            return reward(for: fixed)
        }
        return customRewardMap[categoryID] ?? 0
    }

    var offers: [CardOffer] {
        get { (try? JSONDecoder().decode([CardOffer].self, from: Data(offersData.utf8))) ?? [] }
        set {
            if let data = try? JSONEncoder().encode(newValue), let text = String(data: data, encoding: .utf8) {
                offersData = text
            }
        }
    }
}

enum WelcomeBonusCycle: String, CaseIterable, Identifiable {
    case monthly
    case threeMonths
    case sixMonths
    case yearly

    var id: String { rawValue }
    var title: String {
        switch self {
        case .monthly: return "每月"
        case .threeMonths: return "三个月"
        case .sixMonths: return "六个月"
        case .yearly: return "1年"
        }
    }
}

enum OfferBenefitKind: String, CaseIterable, Identifiable, Codable {
    case credits
    case points

    var id: String { rawValue }
    var title: String { self == .credits ? "Credits" : "Points" }
}

struct CardOffer: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var reminderEnabled: Bool
    var reminderDate: Date
    var benefitKind: OfferBenefitKind
    var benefitValue: Double
    var note: String
}

enum OfferBenefitKind: String, CaseIterable, Identifiable, Codable {
    case credits
    case points

    var id: String { rawValue }
    var title: String { self == .credits ? "Credits" : "Points" }
}

struct CardOffer: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var reminderEnabled: Bool
    var reminderDate: Date
    var benefitKind: OfferBenefitKind
    var benefitValue: Double
    var note: String
}
