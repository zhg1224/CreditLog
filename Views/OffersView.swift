import SwiftUI
import SwiftData

struct OffersView: View {
    @Query(sort: [SortDescriptor(\CreditCard.createdAt, order: .reverse)]) private var cards: [CreditCard]

    var body: some View {
        NavigationStack {
            List {
                ForEach(cards) { card in
                    Section(card.name) {
                        if card.welcomeBonusEnabled {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome Bonus").font(.headline)
                                Text("消费 \(card.welcomeBonusSpendAmount, format: .number) / \(card.welcomeBonusCycle.title)")
                                Text(card.rewardType == .cashBack ? "奖励 $\(card.welcomeBonusValue, format: .number)" : "奖励 \(card.welcomeBonusValue, format: .number) Points")
                            }
                        }

                        if card.offersEnabled {
                            ForEach(card.offers, id: \.id) { offer in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(offer.name).font(.headline)
                                    Text("\(offer.benefitKind.title): \(offer.benefitValue, format: .number)")
                                    if offer.reminderEnabled {
                                        Text("提醒：\(offer.reminderDate.formatted(date: .abbreviated, time: .shortened))")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }

                        if !card.welcomeBonusEnabled && (!card.offersEnabled || card.offers.isEmpty) {
                            Text("暂无 Offer")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Offer")
        }
    }
}
