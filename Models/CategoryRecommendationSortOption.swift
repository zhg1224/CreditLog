//
//  CategoryRecommendationSortOption.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import Foundation

enum CategoryRecommendationSortOption: String, CaseIterable, Identifiable {
    case defaultOrder
    case rewardHighToLow
    case rewardLowToHigh

    var id: String { rawValue }

    var title: String {
        switch self {
        case .defaultOrder:
            return "默认顺序"
        case .rewardHighToLow:
            return "回报值：高到低"
        case .rewardLowToHigh:
            return "回报值：低到高"
        }
    }
}
