//
//  RootTabView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "creditcard.fill")
                }

            CategoriesView()
                .tabItem {
                    Label("类别", systemImage: "square.grid.2x2.fill")
                }
        }
    }
}
