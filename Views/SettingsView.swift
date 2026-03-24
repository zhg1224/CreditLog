//
//  SettingsView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section("类别管理") {
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label("管理返利类别", systemImage: "square.grid.2x2")
                    }
                }

                Section("外观") {
                    Picker("显示模式", selection: $appearanceModeRaw) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
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
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}
