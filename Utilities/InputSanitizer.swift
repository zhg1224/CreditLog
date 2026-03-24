//
//  InputSanitizer.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import Foundation

enum InputSanitizer {
    static func digitsOnly(_ input: String, maxLength: Int? = nil) -> String {
        var filtered = input.filter { $0.isNumber }
        if let maxLength {
            filtered = String(filtered.prefix(maxLength))
        }
        return filtered
    }

    static func decimalOnly(_ input: String) -> String {
        var result = ""
        var hasDecimalPoint = false

        for character in input {
            if character.isNumber {
                result.append(character)
            } else if character == "." && !hasDecimalPoint {
                hasDecimalPoint = true
                if result.isEmpty {
                    result = "0"
                }
                result.append(character)
            }
        }

        return result
    }

    static func integerRangeText(_ input: String, range: ClosedRange<Int>) -> String {
        let digits = digitsOnly(input)
        guard !digits.isEmpty else { return "" }

        if let value = Int(digits) {
            if value < range.lowerBound {
                return "\(range.lowerBound)"
            } else if value > range.upperBound {
                return "\(range.upperBound)"
            } else {
                return "\(value)"
            }
        }

        return ""
    }

    static func leadDaysText(_ input: String) -> String {
        integerRangeText(input, range: 0...365)
    }

    static func dayOfMonthText(_ input: String) -> String {
        integerRangeText(input, range: 1...31)
    }
}
