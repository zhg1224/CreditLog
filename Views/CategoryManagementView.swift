import SwiftUI

struct CategoryManagementView: View {
    @State private var categories: [RewardCategoryItem] = RewardCategoryStore.all()
    @State private var newCategoryName = ""
    @State private var newCategoryIcon = "tag.fill"

    private let iconLibrary = ["fork.knife", "cart.fill", "tram.fill", "fuelpump.fill", "airplane", "bag.fill", "doc.text.fill", "tag.fill", "gift.fill", "sparkles", "star.fill", "gamecontroller.fill", "tv.fill", "bed.double.fill"]

    var body: some View {
        List {
            Section("Reward 类别") {
                ForEach($categories) { $category in
                    HStack {
                        Image(systemName: category.systemImage)
                            .frame(width: 24)
                        TextField("类别名", text: $category.title)
                        Spacer()
                        Menu {
                            ForEach(iconLibrary, id: \.self) { icon in
                                Button {
                                    category.systemImage = icon
                                    persist()
                                } label: { Label(icon, systemImage: icon) }
                            }
                        } label: {
                            Image(systemName: "paintpalette")
                        }
                    }
                }
                .onDelete { offsets in
                    categories.remove(atOffsets: offsets)
                    persist()
                }
                .onChange(of: categories) { _, _ in persist() }
            }

            Section("新增 Reward 类别") {
                TextField("例如：酒店、娱乐", text: $newCategoryName)
                Picker("图标", selection: $newCategoryIcon) {
                    ForEach(iconLibrary, id: \.self) { icon in
                        Label(icon, systemImage: icon).tag(icon)
                    }
                }
                Button("添加类别") {
                    let title = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title.isEmpty else { return }
                    categories.append(.init(id: "custom_\(UUID().uuidString)", title: title, systemImage: newCategoryIcon, isBuiltIn: false))
                    newCategoryName = ""
                    newCategoryIcon = "tag.fill"
                    persist()
                }
                .onDelete { offsets in
                    categories.remove(atOffsets: offsets)
                    persist()
                }
                .onChange(of: categories) { _, _ in persist() }
            }

            Section("新增 Reward 类别") {
                TextField("例如：酒店、娱乐", text: $newCategoryName)
                Picker("图标", selection: $newCategoryIcon) {
                    ForEach(iconLibrary, id: \.self) { icon in
                        Label(icon, systemImage: icon).tag(icon)
                    }
                }
                Button("添加类别") {
                    let title = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title.isEmpty else { return }
                    categories.append(.init(id: "custom_\(UUID().uuidString)", title: title, systemImage: newCategoryIcon, isBuiltIn: false))
                    newCategoryName = ""
                    newCategoryIcon = "tag.fill"
                    persist()
                }
                Button("添加类别") {
                    let title = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title.isEmpty else { return }
                    categories.append(.init(id: "custom_\(UUID().uuidString)", title: title, systemImage: newCategoryIcon, isBuiltIn: false))
                    newCategoryName = ""
                    newCategoryIcon = "tag.fill"
                    persist()
                }
                .onDelete(perform: deleteCustomCategory)
            }

            Section {
                Button("重置默认类别") {
                    RewardCategoryStore.resetToDefault()
                    categories = RewardCategoryStore.all()
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle("Reward 类别")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func persist() {
        let valid = categories.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        RewardCategoryStore.save(all: valid)
    }
}
