//
//  AboutView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import SwiftUI

struct AboutView: View {
    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "版本 \(version) (\(build))"
    }

    var body: some View {
        List {
            Section("应用信息") {
                HStack {
                    Text("应用名称")
                    Spacer()
                    Text("CreditLog")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("版本")
                    Spacer()
                    Text(versionText)
                        .foregroundStyle(.secondary)
                }
            }

            Section("定位") {
                Text("CreditLog 是一个帮助用户管理信用卡 Reward、查看不同消费类别最佳用卡建议、并逐步接入提醒与 iCloud 同步的 iPhone 应用。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("路线图") {
                Text("后续会继续加入：动态返利类别管理、Welcome Bonus、Offer 管理、统一通知总控以及 CloudKit / iCloud 同步。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}
