import Foundation

struct Friend: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var emoji: String

    init(id: UUID = UUID(), name: String, emoji: String) {
        self.id = id
        self.name = name
        self.emoji = emoji
    }
}

enum PayoutMode: String, Codable, CaseIterable {
    case friends
    case charity

    var displayName: String {
        switch self {
        case .friends: "Friends"
        case .charity: "Charity"
        }
    }

    var explanation: String {
        switch self {
        case .friends: "Overage is split among your accountability group."
        case .charity: "Overage is donated to the cause you pick."
        }
    }
}

struct PayoutSettings: Codable, Equatable {
    var mode: PayoutMode
    var friends: [Friend]
    var selectedCharityId: String?

    static let `default` = PayoutSettings(
        mode: .charity,
        friends: [],
        selectedCharityId: "redcross"
    )
}

enum PayoutSettingsStore {
    private static let key = "payoutSettings"

    static func load() -> PayoutSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let settings = try? JSONDecoder().decode(PayoutSettings.self, from: data)
        else { return .default }
        return settings
    }

    static func save(_ settings: PayoutSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
