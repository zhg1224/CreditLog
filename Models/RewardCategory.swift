//
//  RewardCategory.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import Foundation

enum RewardCategory: String, CaseIterable, Identifiable {
    case dining
    case groceries
    case transit
    case gas
    case travel
    case shopping
    case bills

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dining: return "餐饮"
        case .groceries: return "超市"
        case .transit: return "交通"
        case .gas: return "加油"
        case .travel: return "旅行"
        case .shopping: return "购物"
        case .bills: return "账单"
        }
    }

    var systemImage: String {
        switch self {
        case .dining: return "fork.knife"
        case .groceries: return "cart.fill"
        case .transit: return "tram.fill"
        case .gas: return "fuelpump.fill"
        case .travel: return "airplane"
        case .shopping: return "bag.fill"
        case .bills: return "doc.text.fill"
        }
    }
}
