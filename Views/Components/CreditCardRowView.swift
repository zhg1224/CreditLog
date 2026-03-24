//
//  CreditCardRowView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import SwiftUI

struct CreditCardRowView: View {
    let card: CreditCard

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CreditCardVisualView(card: card)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(card.name)
                        .font(.headline)

                    Text("\(card.issuerBank) · \(card.network.title)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 8) {
                infoTag(title: card.rewardType.title, icon: "star.fill")
                infoTag(title: card.foreignTransactionFeeText, icon: "globe")
                infoTag(title: card.feeType.title, icon: "creditcard")
            }
        }
        .padding(16)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.35), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 8)
    }

    @ViewBuilder
    private func infoTag(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(title)
                .lineLimit(1)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
    }
}
