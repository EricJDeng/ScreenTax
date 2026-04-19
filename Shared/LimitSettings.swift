import Foundation
import FamilyControls

struct LimitSettings: Codable, Equatable {
    var dailyMinutes: Int
    var centsPerMinuteOver: Int
    var selection: FamilyActivitySelection

    static let `default` = LimitSettings(
        dailyMinutes: 60,
        centsPerMinuteOver: 25,
        selection: FamilyActivitySelection()
    )
}

enum LimitSettingsStore {
    private static let key = "limitSettings"

    static func load() -> LimitSettings {
        guard let data = AppGroup.sharedDefaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(LimitSettings.self, from: data)
        else { return .default }
        return settings
    }

    static func save(_ settings: LimitSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        AppGroup.sharedDefaults.set(data, forKey: key)
    }
}
