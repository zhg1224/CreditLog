//
//  DashboardFilter.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import Foundation

struct DashboardFilter: Equatable {
    var network: CardNetwork? = nil
    var feePresence: FeePresenceFilter = .all
    var fxFeePresence: FXFeePresenceFilter = .all
    var rewardType: RewardType? = nil

    var activeCount: Int {
        var count = 0
        if network != nil { count += 1 }
        if feePresence != .all { count += 1 }
        if fxFeePresence != .all { count += 1 }
        if rewardType != nil { count += 1 }
        return count
    }

    func matches(_ card: CreditCard) -> Bool {
        if let network, card.network != network {
            return false
        }

        switch feePresence {
        case .all:
            break
        case .hasFee:
            if card.feeAmount <= 0 { return false }
        case .noFee:
            if card.feeAmount > 0 { return false }
        }

        switch fxFeePresence {
        case .all:
            break
        case .hasFXFee:
            if card.foreignTransactionFee <= 0 { return false }
        case .noFXFee:
            if card.foreignTransactionFee > 0 { return false }
        }

        if let rewardType, card.rewardType != rewardType {
            return false
        }

        return true
    }
}

enum FeePresenceFilter: String, CaseIterable, Identifiable {
    case all
    case hasFee
    case noFee

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "全部"
        case .hasFee:
            return "有年费/月费"
        case .noFee:
            return "无年费/月费"
        }
    }
}

enum FXFeePresenceFilter: String, CaseIterable, Identifiable {
    case all
    case hasFXFee
    case noFXFee

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "全部"
        case .hasFXFee:
            return "有外汇手续费"
        case .noFXFee:
            return "无外汇手续费"
        }
    }
}
