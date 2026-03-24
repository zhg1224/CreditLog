//
//  CardNetwork.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import Foundation

enum CardNetwork: String, CaseIterable, Identifiable, Codable {
    case visa
    case mastercard
    case americanExpress

    var id: String { rawValue }

    var title: String {
        switch self {
        case .visa:
            return "Visa"
        case .mastercard:
            return "Mastercard"
        case .americanExpress:
            return "American Express"
        }
    }
}
