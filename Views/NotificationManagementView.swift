import SwiftUI
import SwiftData

struct NotificationManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\CreditCard.createdAt, order: .reverse)]) private var cards: [CreditCard]
    @State private var authorizationStatusText = "尚未检查"

    var body: some View {
        List {
            Section("通知权限") {
                HStack {
                    Text("当前状态")
                    Spacer()
                    Text(authorizationStatusText).foregroundStyle(.secondary)
                }

                Button("请求通知权限") {
                    Task {
                        let granted = await NotificationManager.shared.requestAuthorization()
                        await MainActor.run { authorizationStatusText = granted ? "已授权" : "未授权" }
                    }
                }
            }

            Section("当前已支持的提醒") {
                Label("年/月费提醒", systemImage: "creditcard")
                Label("还款日提醒", systemImage: "calendar")
            }

            Section("按卡片管理") {
                ForEach(cards) { card in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.name).font(.headline)

                        Toggle("年/月费提醒", isOn: Binding(
                            get: { card.feeReminderEnabled },
                            set: { card.feeReminderEnabled = $0; persist(card) }
                        ))

                        Toggle("还款日提醒", isOn: Binding(
                            get: { card.paymentReminderEnabled },
                            set: { card.paymentReminderEnabled = $0; persist(card) }
                        ))
                    }
                }
            }
        }
        .navigationTitle("通知管理")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func persist(_ card: CreditCard) {
        try? modelContext.save()
        Task {
            if card.feeReminderEnabled || card.paymentReminderEnabled {
                let granted = await NotificationManager.shared.requestAuthorization()
                if granted { await NotificationManager.shared.refreshNotifications(for: card) }
            } else {
                NotificationManager.shared.removeNotifications(for: card.id)
            }
        }
    }
}
