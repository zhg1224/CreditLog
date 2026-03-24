//
//  DashboardView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\CreditCard.createdAt, order: .reverse)])
    private var cards: [CreditCard]

    @State private var showAddCard = false
    @State private var showSettings = false
    @State private var showFilterSheet = false

    @State private var dashboardFilter = DashboardFilter()
    @State private var sortOption: DashboardSortOption = .newestFirst

    @State private var selectedCardForEdit: CreditCard?
    @State private var pendingDeleteCard: CreditCard?
    @State private var showDeleteDialog = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                List {
                    heroSection
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)

                    if filteredSortedCards.isEmpty {
                        EmptyStateView(
                            title: cards.isEmpty ? "还没有添加信用卡" : "筛选后没有匹配的信用卡",
                            subtitle: cards.isEmpty ? "点击右上角“+”开始添加第一张卡。" : "请尝试调整筛选条件。",
                            systemImage: cards.isEmpty ? "creditcard" : "line.3.horizontal.decrease.circle"
                        )
                        .padding(.top, 8)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredSortedCards) { card in
                            NavigationLink {
                                CardDetailView(card: card)
                            } label: {
                                CreditCardRowView(card: card)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    pendingDeleteCard = card
                                    showDeleteDialog = true
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    selectedCardForEdit = card
                                } label: {
                                    Label("编辑", systemImage: "square.and.pencil")
                                }
                                .tint(.blue)
                            }
                            .contextMenu {
                                Button {
                                    selectedCardForEdit = card
                                } label: {
                                    Label("编辑", systemImage: "square.and.pencil")
                                }

                                Button(role: .destructive) {
                                    pendingDeleteCard = card
                                    showDeleteDialog = true
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showAddCard = true
                    } label: {
                        Image(systemName: "plus")
                    }

                    Menu {
                        Button {
                            showFilterSheet = true
                        } label: {
                            if dashboardFilter.activeCount > 0 {
                                Label("筛选（\(dashboardFilter.activeCount)）", systemImage: "line.3.horizontal.decrease.circle")
                            } else {
                                Label("筛选", systemImage: "line.3.horizontal.decrease.circle")
                            }
                        }

                        Menu {
                            ForEach(DashboardSortOption.allCases) { option in
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
                        } label: {
                            Label("排序方式", systemImage: "arrow.up.arrow.down")
                        }

                        Button {
                            showSettings = true
                        } label: {
                            Label("设置", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddCard) {
                AddCardView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showFilterSheet) {
                DashboardFilterSheet(filter: $dashboardFilter, issuerOptions: Array(Set(cards.map { $0.issuerBank })).sorted())
            }
            .sheet(item: $selectedCardForEdit) { card in
                EditCardView(card: card)
            }
            .confirmationDialog(
                "删除信用卡",
                isPresented: $showDeleteDialog,
                titleVisibility: .visible
            ) {
                if let card = pendingDeleteCard {
                    Button("删除 \(card.name)", role: .destructive) {
                        deleteCard(card)
                    }
                }

                Button("取消", role: .cancel) {
                    pendingDeleteCard = nil
                }
            } message: {
                Text("删除后会同时移除这张卡关联的提醒通知。")
            }
        }
    }

    private var filteredSortedCards: [CreditCard] {
        let activeCards = cards.filter { !$0.isArchived }
        let filtered = activeCards.filter { dashboardFilter.matches($0) }

        switch sortOption {
        case .newestFirst:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            return filtered.sorted { $0.createdAt < $1.createdAt }
        case .feeHighToLow:
            return filtered.sorted { $0.feeAmount > $1.feeAmount }
        case .feeLowToHigh:
            return filtered.sorted { $0.feeAmount < $1.feeAmount }
        }
    }

    private var heroSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CreditLog")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("你的信用卡与回报总览")
                            .font(.title3.weight(.semibold))
                    }

                    Spacer()

                    Image(systemName: "wallet.pass.fill")
                        .font(.title2)
                        .padding(12)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }

                HStack(spacing: 12) {
                    statPill(title: "卡片数量", value: "\(cards.count)")
                    statPill(title: "筛选结果", value: "\(filteredSortedCards.count)")
                }
            }
        }
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func deleteCard(_ card: CreditCard) {
        NotificationManager.shared.removeNotifications(for: card.id)
        modelContext.delete(card)

        do {
            try modelContext.save()
        } catch {
            print("删除失败: \(error)")
        }

        pendingDeleteCard = nil
        showDeleteDialog = false
    }
}

private struct DashboardFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filter: DashboardFilter

    @State private var selectedNetworkRaw: String
    @State private var selectedIssuerBank: String
    @State private var selectedFeePresenceRaw: String
    @State private var selectedFXFeePresenceRaw: String
    @State private var selectedRewardTypeRaw: String

    let issuerOptions: [String]

    init(filter: Binding<DashboardFilter>, issuerOptions: [String]) {
        self._filter = filter

        self.issuerOptions = issuerOptions

        let current = filter.wrappedValue
        _selectedNetworkRaw = State(initialValue: current.network?.rawValue ?? "")
        _selectedIssuerBank = State(initialValue: current.issuerBank ?? "")
        _selectedFeePresenceRaw = State(initialValue: current.feePresence.rawValue)
        _selectedFXFeePresenceRaw = State(initialValue: current.fxFeePresence.rawValue)
        _selectedRewardTypeRaw = State(initialValue: current.rewardType?.rawValue ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("卡组织") {
                    Picker("卡组织", selection: $selectedNetworkRaw) {
                        Text("全部").tag("")
                        ForEach(CardNetwork.allCases) { network in
                            Text(network.title).tag(network.rawValue)
                        }
                    }
                }

                Section("发卡机构") {
                    Picker("发卡机构", selection: $selectedIssuerBank) {
                        Text("全部").tag("")
                        ForEach(issuerOptions, id: \.self) { issuer in
                            Text(issuer).tag(issuer)
                        }
                    }
                }

                Section("年费 / 月费") {
                    Picker("费用筛选", selection: $selectedFeePresenceRaw) {
                        ForEach(FeePresenceFilter.allCases) { option in
                            Text(option.title).tag(option.rawValue)
                        }
                    }
                }

                Section("外汇手续费") {
                    Picker("外汇手续费筛选", selection: $selectedFXFeePresenceRaw) {
                        ForEach(FXFeePresenceFilter.allCases) { option in
                            Text(option.title).tag(option.rawValue)
                        }
                    }
                }

                Section("Reward 类型") {
                    Picker("Reward 类型", selection: $selectedRewardTypeRaw) {
                        Text("全部").tag("")
                        ForEach(RewardType.allCases) { rewardType in
                            Text(rewardType.title).tag(rewardType.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("筛选")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("重置") {
                        resetSelections()
                        applySelections()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        applySelections()
                        dismiss()
                    }
                }
            }
        }
    }

    private func resetSelections() {
        selectedNetworkRaw = ""
        selectedIssuerBank = ""
        selectedFeePresenceRaw = FeePresenceFilter.all.rawValue
        selectedFXFeePresenceRaw = FXFeePresenceFilter.all.rawValue
        selectedRewardTypeRaw = ""
    }

    private func applySelections() {
        filter.network = selectedNetworkRaw.isEmpty ? nil : CardNetwork(rawValue: selectedNetworkRaw)
        filter.issuerBank = selectedIssuerBank.isEmpty ? nil : selectedIssuerBank
        filter.feePresence = FeePresenceFilter(rawValue: selectedFeePresenceRaw) ?? .all
        filter.fxFeePresence = FXFeePresenceFilter(rawValue: selectedFXFeePresenceRaw) ?? .all
        filter.rewardType = selectedRewardTypeRaw.isEmpty ? nil : RewardType(rawValue: selectedRewardTypeRaw)
    }
}
