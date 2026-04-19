import Foundation

struct LimitSettings: Codable, Equatable {
    var dailyMinutes: Int
    var centsPerMinuteOver: Int
    var watchedAppIds: Set<String>

    static let `default` = LimitSettings(
        dailyMinutes: 60,
        centsPerMinuteOver: 25,
        watchedAppIds: []
    )
}

enum LimitSettingsStore {
    private static let key = "limitSettings"

    static func load() -> LimitSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let settings = try? JSONDecoder().decode(LimitSettings.self, from: data)
        else { return .default }
        return settings
    }

    static func save(_ settings: LimitSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
