//
//  CategoryRecommendationViewModel.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import Foundation

final class CategoryRecommendationViewModel {
    func bestCard(for category: RewardCategory, from cards: [CreditCard]) -> CreditCard? {
        let activeCards = cards.filter { !$0.isArchived }
        guard !activeCards.isEmpty else { return nil }

        return activeCards.max { lhs, rhs in
            lhs.reward(for: category) < rhs.reward(for: category)
        }
    }

    func bestReward(for category: RewardCategory, from cards: [CreditCard]) -> Double {
        bestCard(for: category, from: cards)?.reward(for: category) ?? 0
    }
}
