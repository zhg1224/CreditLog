//
//  CategoriesView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Query(sort: [SortDescriptor(\CreditCard.createdAt, order: .reverse)])
    private var cards: [CreditCard]

    private let viewModel = CategoryRecommendationViewModel()

    @State private var selectedNetworkFilter: CardNetwork?
    @State private var sortOption: CategoryRecommendationSortOption = .defaultOrder

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if cards.isEmpty {
                    EmptyStateView(
                        title: "暂无可分析的信用卡",
                        subtitle: "先去 Dashboard 添加信用卡，系统才能计算最佳回报。",
                        systemImage: "square.grid.2x2"
                    )
                    .padding(.horizontal, 24)
                } else if filteredCards.isEmpty {
                    EmptyStateView(
                        title: "筛选后没有可分析的信用卡",
                        subtitle: "请尝试切换卡组织筛选条件。",
                        systemImage: "line.3.horizontal.decrease.circle"
                    )
                    .padding(.horizontal, 24)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("最佳用卡建议")
                                        .font(.headline)

                                    Text(headerDescription)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            ForEach(sortedEntries) { entry in
                                CategoryRecommendationRow(
                                    category: entry.category,
                                    bestCard: entry.bestCard,
                                    rewardText: rewardText(for: entry.bestCard, value: entry.rewardValue),
                                    detailText: detailText(for: entry.bestCard)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 28)
                    }
                }
            }
            .navigationTitle("消费类别")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("排序方式") {
                            ForEach(CategoryRecommendationSortOption.allCases) { option in
                                Button {
                                    sortOption = option
                                } label: {
                                    if sortOption == option {
                                        Label(option.title, systemImage: "checkmark")
                                    } else {
                                        Text(option.title)
                                    }
                                }
                            }
                        }

                        Section("卡组织筛选") {
                            Button {
                                selectedNetworkFilter = nil
                            } label: {
                                if selectedNetworkFilter == nil {
                                    Label("全部", systemImage: "checkmark")
                                } else {
                                    Text("全部")
                                }
                            }

                            ForEach(CardNetwork.allCases) { network in
                                Button {
                                    selectedNetworkFilter = network
                                } label: {
                                    if selectedNetworkFilter == network {
                                        Label(network.title, systemImage: "checkmark")
                                    } else {
                                        Text(network.title)
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    private var filteredCards: [CreditCard] {
        let activeCards = cards.filter { !$0.isArchived }

        guard let selectedNetworkFilter else {
            return activeCards
        }

        return activeCards.filter { $0.network == selectedNetworkFilter }
    }

    private var headerDescription: String {
        if let selectedNetworkFilter {
            return "当前仅比较 \(selectedNetworkFilter.title) 卡组织下的信用卡，系统会自动给出每个消费类别的推荐卡。"
        } else {
            return "系统会根据你录入的 reward 倍率，自动给出每个消费类别的推荐卡。"
        }
    }

    private var sortedEntries: [CategoryEntry] {
        var entries = RewardCategory.allCases.map { category in
            let bestCard = viewModel.bestCard(for: category, from: filteredCards)
            let rewardValue = viewModel.bestReward(for: category, from: filteredCards)
            return CategoryEntry(category: category, bestCard: bestCard, rewardValue: rewardValue)
        }

        switch sortOption {
        case .defaultOrder:
            return entries
        case .rewardHighToLow:
            entries.sort { $0.rewardValue > $1.rewardValue }
            return entries
        case .rewardLowToHigh:
            entries.sort { $0.rewardValue < $1.rewardValue }
            return entries
        }
    }

    private func rewardText(for card: CreditCard?, value: Double) -> String {
        guard let card else { return "0" }

        switch card.rewardType {
        case .cashBack:
            return String(format: "%.1f%%", value)
        case .pointsReward:
            return String(format: "%.1fX", value)
        }
    }

    private func detailText(for card: CreditCard?) -> String {
        guard let card else { return "" }
        return "\(card.issuerBank) · \(card.network.title)"
    }
}

private struct CategoryEntry: Identifiable {
    let category: RewardCategory
    let bestCard: CreditCard?
    let rewardValue: Double

    var id: String { category.id }
}
