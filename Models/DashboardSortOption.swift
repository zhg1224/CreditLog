//
//  DashboardSortOption.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import Foundation

enum DashboardSortOption: String, CaseIterable, Identifiable {
    case newestFirst
    case oldestFirst
    case feeHighToLow
    case feeLowToHigh

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newestFirst:
            return "添加时间：晚到早"
        case .oldestFirst:
            return "添加时间：早到晚"
        case .feeHighToLow:
            return "年费/月费：高到低"
        case .feeLowToHigh:
            return "年费/月费：低到高"
        }
    }
}
