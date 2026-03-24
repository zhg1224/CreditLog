//
//  CategoryManagementView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-24.
//

import SwiftUI

struct CategoryManagementView: View {
    var body: some View {
        List {
            Section("当前内置类别") {
                ForEach(RewardCategory.allCases) { category in
                    HStack(spacing: 12) {
                        Image(systemName: category.systemImage)
                            .frame(width: 28)

                        Text(category.title)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }

            Section {
                Text("第 3 组会把这里升级成真正可新增 / 删除的类别管理，并同步影响添加卡片、返利推荐和详情页分析。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("类别管理")
        .navigationBarTitleDisplayMode(.inline)
    }
}
