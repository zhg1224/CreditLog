import SwiftUI

struct CreditCardRowView: View {
    let card: CreditCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CreditCardVisualView(card: card)

            HStack(spacing: 8) {
                infoTag(title: card.rewardType.title, icon: "star.fill")
                infoTag(title: topRewardText.first ?? "-", icon: "1.circle.fill")
                infoTag(title: topRewardText.dropFirst().first ?? "-", icon: "2.circle.fill")
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(.white.opacity(0.35), lineWidth: 0.8))
        .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 8)
    }

    private var topRewardText: [String] {
        let rows = RewardCategory.allCases
            .map { ($0.title, card.reward(for: $0)) }
            .sorted { $0.1 > $1.1 }
            .prefix(2)
        return rows.map { title, value in
            let unit = card.rewardType == .pointsReward ? "X" : "%"
            return "\(title) \(String(format: "%.1f", value))\(unit)"
        }
    }

    private func infoTag(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(title).lineLimit(1)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
    }
}
