//
//  RewardType.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import Foundation

enum RewardType: String, CaseIterable, Identifiable, Codable {
    case cashBack
    case pointsReward

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cashBack:
            return "Cash Back"
        case .pointsReward:
            return "Points Reward"
        }
    }
}
