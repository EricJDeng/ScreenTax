import Foundation

enum AppGroup {
    static let identifier = "group.com.screentax.shared"

    static var sharedDefaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: identifier) else {
            fatalError("App Group \(identifier) is not configured — check entitlements.")
        }
        return defaults
    }
}
