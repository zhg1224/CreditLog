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

    // 新结构
    var networkRawValue: String
    var issuerBank: String

    var last4Digits: String

    var feeTypeRawValue: String
    var feeAmount: Double

    var foreignTransactionFee: Double
    var rewardTypeRawValue: String

    var themeName: String
    var customCardImageData: Data?

    var createdAt: Date
    var isArchived: Bool

    // 各消费类别回报倍率
    var rewardDining: Double
    var rewardGroceries: Double
    var rewardTransit: Double
    var rewardGas: Double
    var rewardTravel: Double
    var rewardShopping: Double
    var rewardBills: Double

    // 福利信息
    var benefitName: String
    var benefitExpiryDate: Date?

    // 费用提醒（年费 / 月费共用）
    var feeReminderEnabled: Bool
    var feeReminderLeadDays: Int
    var feeRenewalDate: Date?     // 年费用
    var feeBillingDay: Int?       // 月费用（每月几号）

    // 福利过期提醒
    var benefitReminderEnabled: Bool
    var benefitReminderLeadDays: Int

    // 还款日提醒
    var paymentReminderEnabled: Bool
    var paymentReminderLeadDays: Int
    var paymentDueDay: Int?

    // 每月 reward 检查提醒
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
        foreignTransactionFee: Double = 0,
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
        self.foreignTransactionFee = foreignTransactionFee
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

    // MARK: - Typed Accessors

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

    // MARK: - Backward Compatibility
    // 这些是为了让第二组代码还没改到的旧 View 暂时继续编译通过

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

    // MARK: - Display Helpers

    var maskedNumber: String {
        "•••• \(last4Digits)"
    }

    var feeText: String {
        let suffix = feeType == .annual ? "/年" : "/月"
        if feeAmount == 0 {
            return feeType == .annual ? "无年费" : "$0/月"
        } else {
            return String(format: "$%.2f%@", feeAmount, suffix)
        }
    }

    // 给旧 UI 暂时继续沿用
    var annualFeeText: String {
        feeText
    }

    var foreignTransactionFeeText: String {
        String(format: "%.2f%%", foreignTransactionFee)
    }

    func reward(for category: RewardCategory) -> Double {
        switch category {
        case .dining:
            return rewardDining
        case .groceries:
            return rewardGroceries
        case .transit:
            return rewardTransit
        case .gas:
            return rewardGas
        case .travel:
            return rewardTravel
        case .shopping:
            return rewardShopping
        case .bills:
            return rewardBills
        }
    }
}
