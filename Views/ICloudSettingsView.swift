import SwiftUI

struct ICloudSettingsView: View {
    @State private var cloudKitReady = false

    var body: some View {
        List {
            Section("同步状态") {
                Label(cloudKitReady ? "CloudKit 准备完成（开发阶段）" : "当前仍以本地模式为主", systemImage: cloudKitReady ? "checkmark.icloud" : "internaldrive")
                Toggle("启用 iCloud 同步（即将开放）", isOn: $cloudKitReady)
                    .disabled(true)
            }

            Section("接入准备") {
                Label("已预留设置入口与状态位", systemImage: "gear")
                Label("下一步：Schema、容器配置、迁移策略", systemImage: "list.bullet.clipboard")
                Text("后续会接入 CloudKit / iCloud，同步卡片、类别与 Offer 数据。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("iCloud")
        .navigationBarTitleDisplayMode(.inline)
    }
}
