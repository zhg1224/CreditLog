//
//  CreditCardVisualView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import SwiftUI
import UIKit

struct CreditCardVisualView: View {
    let card: CreditCard

    var body: some View {
        ZStack(alignment: .topLeading) {
            backgroundLayer
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 0.8)
                )
                .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)

            if card.themeName != "custom" {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.issuerBank)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.88))

                            Text(card.network.title)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.white.opacity(0.15), in: Capsule())
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        Image(systemName: "wave.3.right")
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 6) {
                        Text(card.name)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)

                        Text(card.rewardType.title)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.82))
                    }

                    HStack {
                        Text(card.maskedNumber)
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(.white.opacity(0.96))

                        Spacer()

                        Text(card.feeText)
                            .font(.footnote.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.15), in: Capsule())
                            .foregroundStyle(.white)
                    }
                }
                .padding(20)
            }

        }
        .frame(height: 188)
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        if card.themeName == "custom",
           let data = card.customCardImageData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .overlay(
                    LinearGradient(
                        colors: [
                            .black.opacity(0.28),
                            .black.opacity(0.16),
                            .black.opacity(0.32)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        } else {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(cardGradient)
        }
    }

    private var cardGradient: LinearGradient {
        switch card.themeName {
        case "sunset":
            return LinearGradient(
                colors: [.orange, .red, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "forest":
            return LinearGradient(
                colors: [.green, .teal, .indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "plum":
            return LinearGradient(
                colors: [.purple, .indigo, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [.cyan, .blue, .indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
