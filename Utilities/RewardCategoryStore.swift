import Foundation

struct RewardCategoryItem: Identifiable, Hashable, Codable {
    var id: String
    var title: String
    var systemImage: String
    var isBuiltIn: Bool

    static let defaultBuiltIns: [RewardCategoryItem] = RewardCategory.allCases.map {
        RewardCategoryItem(id: $0.rawValue, title: $0.title, systemImage: $0.systemImage, isBuiltIn: true)
    }
}

enum RewardCategoryStore {
    static let key = "reward_categories_v2"

    static func all() -> [RewardCategoryItem] {
        if let data = UserDefaults.standard.data(forKey: key),
           let values = try? JSONDecoder().decode([RewardCategoryItem].self, from: data),
           !values.isEmpty {
            return values
        }
        let initial = RewardCategoryItem.defaultBuiltIns
        save(all: initial)
        return initial
    }

    static func save(all values: [RewardCategoryItem]) {
        if let data = try? JSONEncoder().encode(values) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func resetToDefault() {
        save(all: RewardCategoryItem.defaultBuiltIns)
    }
}
