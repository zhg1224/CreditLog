import Foundation

struct RewardCategoryItem: Identifiable, Hashable, Codable {
    var id: String
    var title: String
    var systemImage: String
    var isBuiltIn: Bool

    static let builtIns: [RewardCategoryItem] = RewardCategory.allCases.map {
        RewardCategoryItem(id: $0.rawValue, title: $0.title, systemImage: $0.systemImage, isBuiltIn: true)
    }
}

enum RewardCategoryStore {
    static let key = "custom_reward_categories_v1"

    static func all() -> [RewardCategoryItem] {
        RewardCategoryItem.builtIns + custom()
    }

    static func custom() -> [RewardCategoryItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let values = try? JSONDecoder().decode([RewardCategoryItem].self, from: data) else {
            return []
        }
        return values
    }

    static func save(custom: [RewardCategoryItem]) {
        if let data = try? JSONEncoder().encode(custom) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
