import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers
import UIKit

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var selectedNetwork: CardNetwork = .visa
    @State private var issuerBank = ""
    @State private var last4Digits = ""

    @State private var selectedRewardType: RewardType = .cashBack
    @State private var selectedFeeType: FeeType = .annual
    @State private var feeEnabled = false
    @State private var feeAmount = ""
    @State private var foreignTransactionFeeEnabled = false
    @State private var foreignTransactionFee = ""

    @State private var selectedTheme = "ocean"
    @State private var customCardImageData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showFileImporter = false

    @State private var welcomeBonusEnabled = false
    @State private var welcomeBonusSpendAmount = ""
    @State private var welcomeBonusCycle: WelcomeBonusCycle = .monthly
    @State private var welcomeBonusValue = ""
    @State private var welcomeBonusExpiryDate = Date()

    @State private var offersEnabled = false
    @State private var offers: [CardOfferForm] = []

    @State private var categoryItems: [RewardCategoryItem] = RewardCategoryStore.all()
    @State private var rewardValues: [String: String] = [:]

    private let facePresets: [CardFacePreset] = [.init(id: "ocean", title: "Ocean"), .init(id: "sunset", title: "Sunset"), .init(id: "forest", title: "Forest"), .init(id: "plum", title: "Plum")]

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                feeAndRewardSection
                rewardSection
                welcomeBonusSection
                offersSection
                cardFaceSection
            }
            .navigationTitle("添加信用卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { Button("保存") { saveCard() }.disabled(!canSave) }
            }
            .onAppear { categoryItems = RewardCategoryStore.all() }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            customCardImageData = cropToCardRatio(data: data)
                            selectedTheme = "custom"
                        }
                    }
                }
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image]) { result in
                if case .success(let url) = result, let data = try? Data(contentsOf: url) {
                    customCardImageData = cropToCardRatio(data: data)
                    selectedTheme = "custom"
                }
            }
        }
    }

    private var basicInfoSection: some View {
        Section("基础信息") {
            TextField("卡片名称", text: $name)
            Picker("卡组织", selection: $selectedNetwork) { ForEach(CardNetwork.allCases) { Text($0.title).tag($0) } }
            TextField("发卡机构", text: $issuerBank)
            TextField("卡号后四位", text: digitsOnlyBinding($last4Digits, maxLength: 4)).keyboardType(.numberPad)
        }
    }

    private var feeAndRewardSection: some View {
        Section("费用与 Reward") {
            Picker("Reward 类型", selection: $selectedRewardType) { ForEach(RewardType.allCases) { Text($0.title).tag($0) } }
                .pickerStyle(.segmented)

            Toggle("填写年费/月费", isOn: $feeEnabled)
            if feeEnabled {
                Picker("费用类型", selection: $selectedFeeType) { ForEach(FeeType.allCases) { Text($0.title).tag($0) } }
                    .pickerStyle(.segmented)
                TextField(selectedFeeType.amountFieldTitle, text: decimalBinding($feeAmount)).keyboardType(.decimalPad)
            }

            Toggle("填写外汇手续费", isOn: $foreignTransactionFeeEnabled)
            if foreignTransactionFeeEnabled {
                TextField("外汇手续费(%)", text: decimalBinding($foreignTransactionFee)).keyboardType(.decimalPad)
            }
        }
    }

    private var rewardSection: some View {
        Section("返利类别") {
            ForEach(categoryItems) { category in
                HStack {
                    Label(category.title, systemImage: category.systemImage)
                    Spacer()
                    TextField("1", text: rewardBinding(for: category.id))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text(selectedRewardType == .pointsReward ? "X" : "%")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var welcomeBonusSection: some View {
        Section("Welcome Bonus") {
            Toggle("启用 Welcome Bonus", isOn: $welcomeBonusEnabled)
            if welcomeBonusEnabled {
                TextField("支付金额", text: decimalBinding($welcomeBonusSpendAmount)).keyboardType(.decimalPad)
                Picker("周期", selection: $welcomeBonusCycle) { ForEach(WelcomeBonusCycle.allCases) { Text($0.title).tag($0) } }
                DatePicker("结束日期", selection: $welcomeBonusExpiryDate, displayedComponents: .date)
                TextField(selectedRewardType == .cashBack ? "Cash Back 金额" : "Points Bonus", text: decimalBinding($welcomeBonusValue))
                    .keyboardType(.decimalPad)
            }
        }
    }

    private var offersSection: some View {
        Section("Offer") {
            Toggle("启用 Offer", isOn: $offersEnabled)
            if offersEnabled {
                ForEach($offers) { $offer in
                    VStack(alignment: .leading) {
                        TextField("Offer 名称", text: $offer.name)
                        Toggle("提醒", isOn: $offer.reminderEnabled)
                        if offer.reminderEnabled { DatePicker("提醒时间", selection: $offer.reminderDate, displayedComponents: [.date, .hourAndMinute]) }
                        Picker("权益类型", selection: $offer.benefitKind) { ForEach(OfferBenefitKind.allCases) { Text($0.title).tag($0) } }
                        TextField("权益数值", text: $offer.benefitValue).keyboardType(.decimalPad)
                        TextField("备注", text: $offer.note)
                    }
                }
                .onDelete { offers.remove(atOffsets: $0) }

                Button { offers.append(CardOfferForm()) } label: { Label("新增 Offer", systemImage: "plus.circle") }
            }
        }
    }

    private var cardFaceSection: some View {
        Section("卡面") {
            Picker("卡面类型", selection: $selectedTheme) {
                ForEach(facePresets) { Text($0.title).tag($0.id) }
                Text("自定义").tag("custom")
            }
            if selectedTheme == "custom" {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) { Label("从相册选择", systemImage: "photo") }
                Button { showFileImporter = true } label: { Label("从文件选择", systemImage: "folder") }
                CardImagePreview(data: customCardImageData)
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !issuerBank.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        last4Digits.count == 4
    }

    private func saveCard() {
        var builtInValues: [RewardCategory: Double] = [:]
        var customValues: [String: Double] = [:]

        for item in categoryItems {
            let value = Double(rewardValues[item.id, default: "1"]) ?? 1
            if let fixed = RewardCategory(rawValue: item.id) { builtInValues[fixed] = value } else { customValues[item.id] = value }
        }

        let newCard = CreditCard(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            network: selectedNetwork,
            issuerBank: issuerBank.trimmingCharacters(in: .whitespacesAndNewlines),
            last4Digits: last4Digits,
            feeType: selectedFeeType,
            feeAmount: feeEnabled ? (Double(feeAmount) ?? 0) : 0,
            feeEnabled: feeEnabled,
            foreignTransactionFee: foreignTransactionFeeEnabled ? (Double(foreignTransactionFee) ?? 0) : 0,
            foreignTransactionFeeEnabled: foreignTransactionFeeEnabled,
            rewardType: selectedRewardType,
            themeName: selectedTheme,
            customCardImageData: selectedTheme == "custom" ? customCardImageData : nil,
            rewardDining: builtInValues[.dining] ?? 1,
            rewardGroceries: builtInValues[.groceries] ?? 1,
            rewardTransit: builtInValues[.transit] ?? 1,
            rewardGas: builtInValues[.gas] ?? 1,
            rewardTravel: builtInValues[.travel] ?? 1,
            rewardShopping: builtInValues[.shopping] ?? 1,
            rewardBills: builtInValues[.bills] ?? 1,
            customRewardsData: jsonString(customValues, fallback: "{}"),
            welcomeBonusEnabled: welcomeBonusEnabled,
            welcomeBonusExpiryDate: welcomeBonusEnabled ? welcomeBonusExpiryDate : nil,
            welcomeBonusSpendAmount: welcomeBonusEnabled ? (Double(welcomeBonusSpendAmount) ?? 0) : 0,
            welcomeBonusCycle: welcomeBonusCycle,
            welcomeBonusValue: welcomeBonusEnabled ? (Double(welcomeBonusValue) ?? 0) : 0,
            offersEnabled: offersEnabled,
            offersData: jsonString(offersEnabled ? offers.map { $0.asModel } : [], fallback: "[]")
        )

        modelContext.insert(newCard)
        try? modelContext.save()
        dismiss()
    }

    private func rewardBinding(for id: String) -> Binding<String> {
        Binding(get: { rewardValues[id, default: "1"] }, set: { rewardValues[id] = InputSanitizer.decimalOnly($0) })
    }

    private func digitsOnlyBinding(_ binding: Binding<String>, maxLength: Int? = nil) -> Binding<String> {
        Binding(get: { binding.wrappedValue }, set: { binding.wrappedValue = InputSanitizer.digitsOnly($0, maxLength: maxLength) })
    }

    private func decimalBinding(_ binding: Binding<String>) -> Binding<String> {
        Binding(get: { binding.wrappedValue }, set: { binding.wrappedValue = InputSanitizer.decimalOnly($0) })
    }

    private func jsonString<T: Encodable>(_ value: T, fallback: String) -> String {
        guard let data = try? JSONEncoder().encode(value), let string = String(data: data, encoding: .utf8) else { return fallback }
        return string
    }

    private func cropToCardRatio(data: Data) -> Data {
        guard let image = UIImage(data: data), let cg = image.cgImage else { return data }
        let ratio: CGFloat = 1.586
        let width = CGFloat(cg.width)
        let height = CGFloat(cg.height)
        let current = width / height
        let rect: CGRect
        if current > ratio {
            let newWidth = height * ratio
            rect = CGRect(x: (width - newWidth) / 2, y: 0, width: newWidth, height: height)
        } else {
            let newHeight = width / ratio
            rect = CGRect(x: 0, y: (height - newHeight) / 2, width: width, height: newHeight)
        }
        guard let cropped = cg.cropping(to: rect) else { return data }
        return UIImage(cgImage: cropped).jpegData(compressionQuality: 0.9) ?? data
    }
}

private struct CardOfferForm: Identifiable {
    var id: UUID = UUID()
    var name = ""
    var reminderEnabled = false
    var reminderDate = Date()
    var benefitKind: OfferBenefitKind = .credits
    var benefitValue = ""
    var note = ""

    var asModel: CardOffer {
        CardOffer(name: name, reminderEnabled: reminderEnabled, reminderDate: reminderDate, benefitKind: benefitKind, benefitValue: Double(benefitValue) ?? 0, note: note)
    }
}

private struct CardFacePreset: Identifiable {
    let id: String
    let title: String
}

private struct CardImagePreview: View {
    let data: Data?
    var body: some View {
        if let data, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}
