//
//  CreditLogApp.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import SwiftUI
import SwiftData
import os

@main
struct CreditLogApp: App {
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue

    private let modelContainer: ModelContainer = Self.makeModelContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(
                    AppearanceMode(rawValue: appearanceModeRaw)?.colorScheme
                )
        }
        .modelContainer(modelContainer)
    }
}

private extension CreditLogApp {
    static func makeModelContainer() -> ModelContainer {
        let logger = Logger(subsystem: "CreditLog", category: "SwiftData")

        #if DEBUG
        let useInMemoryStore = ProcessInfo.processInfo.arguments.contains("-UseInMemoryStore")
        #else
        let useInMemoryStore = false
        #endif

        do {
            if useInMemoryStore {
                logger.info("当前使用内存模式 ModelContainer（仅开发调试）")
                let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
                return try ModelContainer(
                    for: CreditCard.self,
                    configurations: configuration
                )
            } else {
                logger.info("当前使用持久化模式 ModelContainer")
                return try ModelContainer(for: CreditCard.self)
            }
        } catch {
            logger.error("创建持久化 ModelContainer 失败: \(error.localizedDescription)")

            #if DEBUG
            logger.warning("DEBUG 环境下自动回退到内存模式，避免应用启动崩溃")
            do {
                let fallbackConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
                return try ModelContainer(
                    for: CreditCard.self,
                    configurations: fallbackConfiguration
                )
            } catch {
                logger.fault("回退到内存模式也失败: \(error.localizedDescription)")
                fatalError("无法创建任何可用的 ModelContainer: \(error)")
            }
            #else
            fatalError("无法创建持久化 ModelContainer: \(error)")
            #endif
        }
    }
}
