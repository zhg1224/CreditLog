import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Query(sort: [SortDescriptor(\CreditCard.createdAt, order: .reverse)])
    private var cards: [CreditCard]

    private let viewModel = CategoryRecommendationViewModel()

    @State private var selectedIssuerFilter: String?
    @State private var selectedRewardFilter: RewardTypeFilter = .all
    @State private var sortOption: CategoryRecommendationSortOption = .rewardHighToLow

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                if filteredCards.isEmpty {
                    EmptyStateView(title: "暂无可分析的信用卡", subtitle: "先去 Dashboard 添加信用卡，系统才能计算最佳回报。", systemImage: "square.grid.2x2")
                        .padding(.horizontal, 24)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            if selectedRewardFilter != .pointsOnly {
                                rewardBlock(title: "Cash Back", cards: filteredCards.filter { $0.rewardType == .cashBack })
                            }
                            if selectedRewardFilter != .cashOnly {
                                rewardBlock(title: "Points Reward", cards: filteredCards.filter { $0.rewardType == .pointsReward })
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("消费类别")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Reward 类型") {
                            ForEach(RewardTypeFilter.allCases) { option in
                                Button { selectedRewardFilter = option } label: {
                                    if selectedRewardFilter == option { Label(option.title, systemImage: "checkmark") } else { Text(option.title) }
                                }
                            }
                        }
                        Section("排序方式") {
                            ForEach(CategoryRecommendationSortOption.allCases) { option in
                                Button { sortOption = option } label: {
                                    if sortOption == option { Label(option.title, systemImage: "checkmark") } else { Text(option.title) }
                                }
                            }
                        }
                        Section("发卡机构筛选") {
                            Button { selectedIssuerFilter = nil } label: {
                                if selectedIssuerFilter == nil { Label("全部", systemImage: "checkmark") } else { Text("全部") }
                            }
                            ForEach(issuerOptions, id: \.self) { issuer in
                                Button { selectedIssuerFilter = issuer } label: {
                                    if selectedIssuerFilter == issuer { Label(issuer, systemImage: "checkmark") } else { Text(issuer) }
                                }
                            }
                        }
                    } label: { Image(systemName: "ellipsis.circle") }
                }
            }
        }
    }

    private var issuerOptions: [String] {
        Array(Set(cards.map { $0.issuerBank })).sorted()
    }

    private var filteredCards: [CreditCard] {
        let active = cards.filter { !$0.isArchived }
        if let issuer = selectedIssuerFilter { return active.filter { $0.issuerBank == issuer } }
        return active
    }

    private func rewardBlock(title: String, cards: [CreditCard]) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title).font(.headline)
                ForEach(sortedEntries(from: cards)) { entry in
                    CategoryRecommendationRow(
                        category: RewardCategory(rawValue: entry.categoryID) ?? .dining,
                        bestCard: entry.bestCard,
                        rewardText: entry.bestCard == nil ? "0" : formatted(entry.rewardValue, type: entry.bestCard?.rewardType ?? .cashBack),
                        detailText: entry.bestCard.map { "\($0.issuerBank) · \($0.network.title)" } ?? ""
                    )
                }
                ForEach(sortedCustomEntries(from: cards), id: \.categoryID) { entry in
                    HStack {
                        Text(entry.title)
                        Spacer()
                        Text(formatted(entry.rewardValue, type: entry.bestCard?.rewardType ?? .cashBack))
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func sortedEntries(from sourceCards: [CreditCard]) -> [CategoryEntry] {
        var entries = RewardCategory.allCases.map { category in
            CategoryEntry(categoryID: category.rawValue, title: category.title, bestCard: viewModel.bestCard(for: category, from: sourceCards), rewardValue: viewModel.bestReward(for: category, from: sourceCards))
        }
        switch sortOption {
        case .defaultOrder: break
        case .rewardHighToLow: entries.sort { $0.rewardValue > $1.rewardValue }
        case .rewardLowToHigh: entries.sort { $0.rewardValue < $1.rewardValue }
        }
        return entries
    }

    private func sortedCustomEntries(from sourceCards: [CreditCard]) -> [CategoryEntry] {
        let custom = RewardCategoryStore.custom()
        var entries = custom.map { item in
            let best = sourceCards.max { $0.rewardValue(for: item.id) < $1.rewardValue(for: item.id) }
            return CategoryEntry(categoryID: item.id, title: item.title, bestCard: best, rewardValue: best?.rewardValue(for: item.id) ?? 0)
        }
        switch sortOption {
        case .defaultOrder: break
        case .rewardHighToLow: entries.sort { $0.rewardValue > $1.rewardValue }
        case .rewardLowToHigh: entries.sort { $0.rewardValue < $1.rewardValue }
        }
        return entries
    }

    private func formatted(_ value: Double, type: RewardType) -> String {
        type == .pointsReward ? String(format: "%.1fX", value) : String(format: "%.1f%%", value)
    }
}

private struct CategoryEntry: Identifiable {
    let categoryID: String
    let title: String
    let bestCard: CreditCard?
    let rewardValue: Double
    var id: String { categoryID }
}

enum RewardTypeFilter: String, CaseIterable, Identifiable {
    case all, cashOnly, pointsOnly
    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: return "全部"
        case .cashOnly: return "仅 Cash Back"
        case .pointsOnly: return "仅 Points Reward"
        }
    }
}
