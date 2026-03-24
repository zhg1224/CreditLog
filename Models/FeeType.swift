//
//  FeeType.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import Foundation

enum FeeType: String, CaseIterable, Identifiable, Codable {
    case annual
    case monthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .annual:
            return "年费"
        case .monthly:
            return "月费"
        }
    }

    var amountFieldTitle: String {
        switch self {
        case .annual:
            return "费用金额"
        case .monthly:
            return "费用金额"
        }
    }

    var suffixTitle: String {
        switch self {
        case .annual:
            return "/年"
        case .monthly:
            return "/月"
        }
    }
}
