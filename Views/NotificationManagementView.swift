//
//  NotificationManagementView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import SwiftUI

struct NotificationManagementView: View {
    @State private var authorizationStatusText = "尚未检查"

    var body: some View {
        List {
            Section("通知权限") {
                HStack {
                    Text("当前状态")
                    Spacer()
                    Text(authorizationStatusText)
                        .foregroundStyle(.secondary)
                }

                Button("请求通知权限") {
                    Task {
                        let granted = await NotificationManager.shared.requestAuthorization()
                        await MainActor.run {
                            authorizationStatusText = granted ? "已授权" : "未授权"
                        }
                    }
                }
            }

            Section("当前已支持的提醒") {
                Label("费用提醒（年费 / 月费）", systemImage: "creditcard")
                Label("福利过期提醒", systemImage: "gift")
                Label("还款日提醒", systemImage: "calendar")
                Label("每月 reward 检查提醒", systemImage: "arrow.clockwise")
            }

            Section {
                Text("第 4 组会把这里升级为真正的统一通知管理页面，包括每张卡的提醒开关、提前天数、Welcome Bonus 与 Offer 提醒。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("通知管理")
        .navigationBarTitleDisplayMode(.inline)
    }
}
