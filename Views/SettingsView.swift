import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section("Reward 类别") {
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label("管理 Reward 类别", systemImage: "square.grid.2x2")
                    }
                }

                Section("外观") {
                    Picker("", selection: $appearanceModeRaw) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }

                Section("通知") {
                    NavigationLink {
                        NotificationManagementView()
                    } label: {
                        Label("通知管理", systemImage: "bell.badge")
                    }
                }

                Section("iCloud") {
                    NavigationLink {
                        ICloudSettingsView()
                    } label: {
                        Label("iCloud", systemImage: "icloud")
                    }
                }

                Section("关于") {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("关于 CreditLog", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
