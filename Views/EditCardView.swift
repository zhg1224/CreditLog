//
//  EditCardView.swift
//  CreditLog
//
//  Created by Zhao Zhang on 2026-03-23.
//

import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers
import UIKit

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let card: CreditCard

    // 基础信息
    @State private var name: String
    @State private var selectedNetwork: CardNetwork
    @State private var issuerBank: String
    @State private var last4Digits: String

    // 费用与回报
    @State private var selectedFeeType: FeeType
    @State private var feeAmount: String
    @State private var foreignTransactionFee: String
    @State private var selectedRewardType: RewardType

    // 回报倍率
    @State private var RewardDining: String
    @State private var RewardGroceries: String
    @State private var RewardTransit: String
    @State private var RewardGas: String
    @State private var RewardTravel: String
    @State private var RewardShopping: String
    @State private var RewardBills: String

    // 卡面
    @State private var selectedTheme: String
    @State private var customCardImageData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showFileImporter = false

    // 福利信息
    @State private var benefitName: String
    @State private var benefitExpiryDate: Date

    // 提醒：费用
    @State private var feeReminderEnabled: Bool
    @State private var feeReminderLeadDays: String
    @State private var feeRenewalDate: Date
    @State private var feeBillingDay: String

    // 提醒：福利
    @State private var benefitReminderEnabled: Bool
    @State private var benefitReminderLeadDays: String

    // 提醒：还款
    @State private var paymentReminderEnabled: Bool
    @State private var paymentReminderLeadDays: String
    @State private var paymentDueDay: String

    // 提醒：每月检查 Reward
    @State private var monthlyReviewReminderEnabled: Bool
    @State private var monthlyReviewLeadDays: String
    @State private var monthlyReviewDay: String

    private let facePresets: [CardFacePreset] = [
        .init(id: "ocean", title: "Ocean"),
        .init(id: "sunset", title: "Sunset"),
        .init(id: "forest", title: "Forest"),
        .init(id: "plum", title: "Plum")
    ]

    init(card: CreditCard) {
        self.card = card

        _name = State(initialValue: card.name)
        _selectedNetwork = State(initialValue: card.network)
        _issuerBank = State(initialValue: card.issuerBank)
        _last4Digits = State(initialValue: card.last4Digits)

        _selectedFeeType = State(initialValue: card.feeType)
        _feeAmount = State(initialValue: card.feeAmount == 0 ? "" : String(card.feeAmount))
        _foreignTransactionFee = State(initialValue: card.foreignTransactionFee == 0 ? "" : String(card.foreignTransactionFee))
        _selectedRewardType = State(initialValue: card.RewardType)

        _RewardDining = State(initialValue: String(card.RewardDining))
        _RewardGroceries = State(initialValue: String(card.RewardGroceries))
        _RewardTransit = State(initialValue: String(card.RewardTransit))
        _RewardGas = State(initialValue: String(card.RewardGas))
        _RewardTravel = State(initialValue: String(card.RewardTravel))
        _RewardShopping = State(initialValue: String(card.RewardShopping))
        _RewardBills = State(initialValue: String(card.RewardBills))

        _selectedTheme = State(initialValue: card.themeName)
        _customCardImageData = State(initialValue: card.customCardImageData)

        _benefitName = State(initialValue: card.benefitName)
        _benefitExpiryDate = State(initialValue: card.benefitExpiryDate ?? .now)

        _feeReminderEnabled = State(initialValue: card.feeReminderEnabled)
        _feeReminderLeadDays = State(initialValue: String(card.feeReminderLeadDays))
        _feeRenewalDate = State(initialValue: card.feeRenewalDate ?? .now)
        _feeBillingDay = State(initialValue: card.feeBillingDay.map(String.init) ?? "1")

        _benefitReminderEnabled = State(initialValue: card.benefitReminderEnabled)
        _benefitReminderLeadDays = State(initialValue: String(card.benefitReminderLeadDays))

        _paymentReminderEnabled = State(initialValue: card.paymentReminderEnabled)
        _paymentReminderLeadDays = State(initialValue: String(card.paymentReminderLeadDays))
        _paymentDueDay = State(initialValue: card.paymentDueDay.map(String.init) ?? "1")

        _monthlyReviewReminderEnabled = State(initialValue: card.monthlyReviewReminderEnabled)
        _monthlyReviewLeadDays = State(initialValue: String(card.monthlyReviewLeadDays))
        _monthlyReviewDay = State(initialValue: card.monthlyReviewDay.map(String.init) ?? "1")
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                feeAndRewardSection
                RewardMultiplierSection
                cardFaceSection
                benefitSection
                reminderSection
            }
            .navigationTitle("编辑信用卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        saveChanges()
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
                ForEach(RewardType.allCases) { RewardType in
                    Text(RewardType.title).tag(RewardType)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var RewardMultiplierSection: some View {
        Section("消费 Reward 倍率") {
            RewardField(title: "餐饮", value: decimalBinding($RewardDining))
            RewardField(title: "超市", value: decimalBinding($RewardGroceries))
            RewardField(title: "交通", value: decimalBinding($RewardTransit))
            RewardField(title: "加油", value: decimalBinding($RewardGas))
            RewardField(title: "旅行", value: decimalBinding($RewardTravel))
            RewardField(title: "购物", value: decimalBinding($RewardShopping))
            RewardField(title: "账单", value: decimalBinding($RewardBills))
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

            Toggle("每月 Reward 检查提醒", isOn: $monthlyReviewReminderEnabled)
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

    private func RewardField(title: String, value: Binding<String>) -> some View {
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

    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedIssuerBank = issuerBank.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBenefitName = benefitName.trimmingCharacters(in: .whitespacesAndNewlines)

        card.name = trimmedName
        card.network = selectedNetwork
        card.issuerBank = trimmedIssuerBank
        card.last4Digits = last4Digits

        card.feeType = selectedFeeType
        card.feeAmount = Double(feeAmount) ?? 0
        card.foreignTransactionFee = Double(foreignTransactionFee) ?? 0
        card.RewardType = selectedRewardType

        card.themeName = selectedTheme
        card.customCardImageData = customCardImageData

        card.rewardDining = Double(RewardDining) ?? 1
        card.rewardGroceries = Double(RewardGroceries) ?? 1
        card.rewardTransit = Double(RewardTransit) ?? 1
        card.rewardGas = Double(RewardGas) ?? 1
        card.rewardTravel = Double(RewardTravel) ?? 1
        card.rewardShopping = Double(RewardShopping) ?? 1
        card.rewardBills = Double(RewardBills) ?? 1

        card.benefitName = trimmedBenefitName
        card.benefitExpiryDate = trimmedBenefitName.isEmpty ? nil : benefitExpiryDate

        card.feeReminderEnabled = feeReminderEnabled
        card.feeReminderLeadDays = Int(feeReminderLeadDays) ?? 0
        card.feeRenewalDate = selectedFeeType == .annual && feeReminderEnabled ? feeRenewalDate : nil
        card.feeBillingDay = selectedFeeType == .monthly && feeReminderEnabled ? Int(feeBillingDay) : nil

        card.benefitReminderEnabled = benefitReminderEnabled
        card.benefitReminderLeadDays = Int(benefitReminderLeadDays) ?? 0

        card.paymentReminderEnabled = paymentReminderEnabled
        card.paymentReminderLeadDays = Int(paymentReminderLeadDays) ?? 0
        card.paymentDueDay = paymentReminderEnabled ? Int(paymentDueDay) : nil

        card.monthlyReviewReminderEnabled = monthlyReviewReminderEnabled
        card.monthlyReviewLeadDays = Int(monthlyReviewLeadDays) ?? 0
        card.monthlyReviewDay = monthlyReviewReminderEnabled ? Int(monthlyReviewDay) : nil

        do {
            try modelContext.save()
        } catch {
            print("保存修改失败: \(error)")
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
                    await NotificationManager.shared.refreshNotifications(for: card)
                }
            } else {
                NotificationManager.shared.removeNotifications(for: card.id)
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
