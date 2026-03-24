//
//  ICloudSettingsView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import SwiftUI

struct ICloudSettingsView: View {
    var body: some View {
        List {
            Section("同步状态") {
                Label("当前仍以本地 / 开发模式为主", systemImage: "internaldrive")
                Label("CloudKit / iCloud 接入将在后续分组完成", systemImage: "icloud")
            }

            Section("后续计划") {
                Text("第 5 组会开始准备 CloudKit / iCloud 同步能力，包括设置页状态展示、同步说明和后续数据兼容策略。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("iCloud")
        .navigationBarTitleDisplayMode(.inline)
    }
}
