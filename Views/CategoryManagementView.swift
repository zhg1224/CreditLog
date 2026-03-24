//
//  CategoryManagementView.swift
//  CreditLog
//

import SwiftUI

struct CategoryManagementView: View {
    @State private var customCategories: [RewardCategoryItem] = RewardCategoryStore.custom()
    @State private var newCategoryName = ""

    var body: some View {
        List {
            Section("当前类别") {
                ForEach(RewardCategoryItem.builtIns) { category in
                    categoryRow(category)
                }

                ForEach(customCategories) { category in
                    categoryRow(category)
                }
                .onDelete(perform: deleteCustomCategory)
            }

            Section("新增类别") {
                TextField("例如：酒店、流媒体", text: $newCategoryName)
                Button("添加类别") { addCategory() }
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("类别管理")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func categoryRow(_ category: RewardCategoryItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: category.systemImage)
                .frame(width: 28)
            Text(category.title)
            Spacer()
            if category.isBuiltIn {
                Text("内置")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }

    private func addCategory() {
        let title = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let id = "custom_\(UUID().uuidString)"
        customCategories.append(.init(id: id, title: title, systemImage: "tag.fill", isBuiltIn: false))
        RewardCategoryStore.save(custom: customCategories)
        newCategoryName = ""
    }

    private func deleteCustomCategory(at offsets: IndexSet) {
        customCategories.remove(atOffsets: offsets)
        RewardCategoryStore.save(custom: customCategories)
    }
}
