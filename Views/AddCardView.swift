//
//  AddCardView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers
import UIKit

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // 基础信息
    @State private var name = ""
    @State private var selectedNetwork: CardNetwork = .visa
    @State private var issuerBank = ""
    @State private var last4Digits = ""

    // 费用与回报
    @State private var selectedFeeType: FeeType = .annual
    @State private var feeAmount = ""
    @State private var foreignTransactionFee = ""
    @State private var selectedRewardType: RewardType = .cashBack

    // 回报倍率
    @State private var rewardDining = "1"
    @State private var rewardGroceries = "1"
    @State private var rewardTransit = "1"
    @State private var rewardGas = "1"
    @State private var rewardTravel = "1"
    @State private var rewardShopping = "1"
    @State private var rewardBills = "1"

    // 卡面
    @State private var selectedTheme = "ocean"
    @State private var customCardImageData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showFileImporter = false

    // 福利信息
    @State private var benefitName = ""
    @State private var benefitExpiryDate = Date()

    // 提醒：费用
    @State private var feeReminderEnabled = false
    @State private var feeReminderLeadDays = "30"
    @State private var feeRenewalDate = Date()
    @State private var feeBillingDay = "1"

    // 提醒：福利
    @State private var benefitReminderEnabled = false
    @State private var benefitReminderLeadDays = "14"

    // 提醒：还款
    @State private var paymentReminderEnabled = false
    @State private var paymentReminderLeadDays = "3"
    @State private var paymentDueDay = "1"

    // 提醒：每月检查 reward
    @State private var monthlyReviewReminderEnabled = false
    @State private var monthlyReviewLeadDays = "0"
    @State private var monthlyReviewDay = "1"

    private let facePresets: [CardFacePreset] = [
        .init(id: "ocean", title: "Ocean"),
        .init(id: "sunset", title: "Sunset"),
        .init(id: "forest", title: "Forest"),
        .init(id: "plum", title: "Plum")
    ]

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                feeAndRewardSection
                rewardMultiplierSection
                cardFaceSection
                benefitSection
                reminderSection
            }
            .navigationTitle("添加信用卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        saveCard()
                    }
                    .disabled(!canSave)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }

                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            customCardImageData = data
                            selectedTheme = "custom"
                        }
                    }
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.image]
            ) { result in
                handleFileImport(result)
            }
        }
    }

    // MARK: - Sections

    private var basicInfoSection: some View {
        Section("基础信息") {
            TextField("卡片名称", text: $name)

            Picker("卡组织", selection: $selectedNetwork) {
                ForEach(CardNetwork.allCases) { network in
                    Text(network.title).tag(network)
                }
            }

            TextField("发卡银行", text: $issuerBank)

            TextField("卡号后四位", text: digitsOnlyBinding($last4Digits, maxLength: 4))
                .keyboardType(.numberPad)
        }
    }

    private var feeAndRewardSection: some View {
        Section("费用与回报类型") {
            Picker("费用类型", selection: $selectedFeeType) {
                ForEach(FeeType.allCases) { feeType in
                    Text(feeType.title).tag(feeType)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                TextField(selectedFeeType.amountFieldTitle, text: decimalBinding($feeAmount))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)

                Text(selectedFeeType.suffixTitle)
                    .foregroundStyle(.secondary)
            }

            HStack {
                TextField("外币手续费", text: decimalBinding($foreignTransactionFee))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)

                Text("%")
                    .foregroundStyle(.secondary)
            }

            Picker("Reward 类型", selection: $selectedRewardType) {
                ForEach(RewardType.allCases) { rewardType in
                    Text(rewardType.title).tag(rewardType)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var rewardMultiplierSection: some View {
        Section("消费返利倍数") {
            rewardField(title: "餐饮", value: decimalBinding($rewardDining))
            rewardField(title: "超市", value: decimalBinding($rewardGroceries))
            rewardField(title: "交通", value: decimalBinding($rewardTransit))
            rewardField(title: "加油", value: decimalBinding($rewardGas))
            rewardField(title: "旅行", value: decimalBinding($rewardTravel))
            rewardField(title: "购物", value: decimalBinding($rewardShopping))
            rewardField(title: "账单", value: decimalBinding($rewardBills))
        }
    }

    private var cardFaceSection: some View {
        Section("卡面") {
            Picker("默认卡面", selection: $selectedTheme) {
                ForEach(facePresets) { preset in
                    Text(preset.title).tag(preset.id)
                }

                if customCardImageData != nil {
                    Text("自定义卡面").tag("custom")
                }
            }

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label("从相册选择卡面", systemImage: "photo")
            }

            Button {
                showFileImporter = true
            } label: {
                Label("从文件选择卡面", systemImage: "folder")
            }

            CardImagePreview(data: customCardImageData)
        }
    }

    private var benefitSection: some View {
        Section("福利信息") {
            TextField("福利名称", text: $benefitName)

            DatePicker(
                "福利过期日期",
                selection: $benefitExpiryDate,
                displayedComponents: .date
            )
        }
    }

    private var reminderSection: some View {
        Section("提醒设置") {
            Toggle("费用提醒", isOn: $feeReminderEnabled)
            if feeReminderEnabled {
                feeReminderFields
            }

            Toggle("福利过期提醒", isOn: $benefitReminderEnabled)
            if benefitReminderEnabled {
                TextField("提前几天提醒", text: leadDaysBinding($benefitReminderLeadDays))
                    .keyboardType(.numberPad)
            }

            Toggle("还款日提醒", isOn: $paymentReminderEnabled)
            if paymentReminderEnabled {
                TextField("每月还款日", text: dayOfMonthBinding($paymentDueDay))
                    .keyboardType(.numberPad)

                TextField("提前几天提醒", text: leadDaysBinding($paymentReminderLeadDays))
                    .keyboardType(.numberPad)
            }

            Toggle("每月 reward 检查提醒", isOn: $monthlyReviewReminderEnabled)
            if monthlyReviewReminderEnabled {
                TextField("每月检查日", text: dayOfMonthBinding($monthlyReviewDay))
                    .keyboardType(.numberPad)

                TextField("提前几天提醒", text: leadDaysBinding($monthlyReviewLeadDays))
                    .keyboardType(.numberPad)
            }
        }
    }

    @ViewBuilder
    private var feeReminderFields: some View {
        if selectedFeeType == .annual {
            DatePicker(
                "续费日期",
                selection: $feeRenewalDate,
                displayedComponents: .date
            )
        } else {
            TextField("每月扣费日", text: dayOfMonthBinding($feeBillingDay))
                .keyboardType(.numberPad)
        }

        TextField("提前几天提醒", text: leadDaysBinding($feeReminderLeadDays))
            .keyboardType(.numberPad)
    }

    // MARK: - Helpers

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !issuerBank.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        last4Digits.count == 4 &&
        !feeAmount.isEmpty
    }

    private func rewardField(title: String, value: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("1", text: value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)
        }
    }

    private func digitsOnlyBinding(_ binding: Binding<String>, maxLength: Int? = nil) -> Binding<String> {
        Binding(
            get: { binding.wrappedValue },
            set: { newValue in
                binding.wrappedValue = InputSanitizer.digitsOnly(newValue, maxLength: maxLength)
            }
        )
    }

    private func decimalBinding(_ binding: Binding<String>) -> Binding<String> {
        Binding(
            get: { binding.wrappedValue },
            set: { newValue in
                binding.wrappedValue = InputSanitizer.decimalOnly(newValue)
            }
        )
    }

    private func leadDaysBinding(_ binding: Binding<String>) -> Binding<String> {
        Binding(
            get: { binding.wrappedValue },
            set: { newValue in
                binding.wrappedValue = InputSanitizer.leadDaysText(newValue)
            }
        )
    }

    private func dayOfMonthBinding(_ binding: Binding<String>) -> Binding<String> {
        Binding(
            get: { binding.wrappedValue },
            set: { newValue in
                binding.wrappedValue = InputSanitizer.dayOfMonthText(newValue)
            }
        )
    }

    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let accessed = url.startAccessingSecurityScopedResource()
            defer {
                if accessed {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            if let data = try? Data(contentsOf: url) {
                customCardImageData = data
                selectedTheme = "custom"
            }

        case .failure(let error):
            print("文件导入失败: \(error)")
        }
    }

    private func saveCard() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedIssuerBank = issuerBank.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBenefitName = benefitName.trimmingCharacters(in: .whitespacesAndNewlines)

        let newCard = CreditCard(
            name: trimmedName,
            network: selectedNetwork,
            issuerBank: trimmedIssuerBank,
            last4Digits: last4Digits,
            feeType: selectedFeeType,
            feeAmount: Double(feeAmount) ?? 0,
            foreignTransactionFee: Double(foreignTransactionFee) ?? 0,
            rewardType: selectedRewardType,
            themeName: selectedTheme,
            customCardImageData: customCardImageData,
            rewardDining: Double(rewardDining) ?? 1,
            rewardGroceries: Double(rewardGroceries) ?? 1,
            rewardTransit: Double(rewardTransit) ?? 1,
            rewardGas: Double(rewardGas) ?? 1,
            rewardTravel: Double(rewardTravel) ?? 1,
            rewardShopping: Double(rewardShopping) ?? 1,
            rewardBills: Double(rewardBills) ?? 1,
            benefitName: trimmedBenefitName,
            benefitExpiryDate: trimmedBenefitName.isEmpty ? nil : benefitExpiryDate,
            feeReminderEnabled: feeReminderEnabled,
            feeReminderLeadDays: Int(feeReminderLeadDays) ?? 0,
            feeRenewalDate: selectedFeeType == .annual && feeReminderEnabled ? feeRenewalDate : nil,
            feeBillingDay: selectedFeeType == .monthly && feeReminderEnabled ? Int(feeBillingDay) : nil,
            benefitReminderEnabled: benefitReminderEnabled,
            benefitReminderLeadDays: Int(benefitReminderLeadDays) ?? 0,
            paymentReminderEnabled: paymentReminderEnabled,
            paymentReminderLeadDays: Int(paymentReminderLeadDays) ?? 0,
            paymentDueDay: paymentReminderEnabled ? Int(paymentDueDay) : nil,
            monthlyReviewReminderEnabled: monthlyReviewReminderEnabled,
            monthlyReviewLeadDays: Int(monthlyReviewLeadDays) ?? 0,
            monthlyReviewDay: monthlyReviewReminderEnabled ? Int(monthlyReviewDay) : nil
        )

        modelContext.insert(newCard)

        do {
            try modelContext.save()
        } catch {
            print("保存信用卡失败: \(error)")
        }

        Task {
            let needPermission =
                feeReminderEnabled ||
                benefitReminderEnabled ||
                paymentReminderEnabled ||
                monthlyReviewReminderEnabled

            if needPermission {
                let granted = await NotificationManager.shared.requestAuthorization()
                if granted {
                    await NotificationManager.shared.refreshNotifications(for: newCard)
                }
            }
        }

        dismiss()
    }
}

private struct CardFacePreset: Identifiable {
    let id: String
    let title: String
}

private struct CardImagePreview: View {
    let data: Data?

    var body: some View {
        Group {
            if let data,
               let uiImage = UIImage(data: data) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("当前自定义卡面预览")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(.vertical, 4)
            }
        }
    }
}
