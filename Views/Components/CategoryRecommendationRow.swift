//
//  ategoryRecommendationRow.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import SwiftUI

struct CategoryRecommendationRow: View {
    let category: RewardCategory
    let bestCard: CreditCard?
    let rewardText: String
    let detailText: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: category.systemImage)
                .font(.title3)
                .frame(width: 46, height: 46)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(category.title)
                    .font(.headline)

                Text(bestCard?.name ?? "暂无推荐")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if !detailText.isEmpty {
                    Text(detailText)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(rewardText)
                    .font(.headline)

                Text("最高回报")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.35), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.05), radius: 14, x: 0, y: 8)
    }
}
