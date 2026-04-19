import DeviceActivity
import Foundation

enum MonitoringController {
    static let activityName = DeviceActivityName("ScreenTax.Daily")
    static let eventName = DeviceActivityEvent.Name("ScreenTax.LimitReached")

    static func start(with settings: LimitSettings) throws {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        let event = DeviceActivityEvent(
            applications: settings.selection.applicationTokens,
            categories: settings.selection.categoryTokens,
            webDomains: settings.selection.webDomainTokens,
            threshold: DateComponents(minute: settings.dailyMinutes)
        )
        let center = DeviceActivityCenter()
        center.stopMonitoring([activityName])
        try center.startMonitoring(
            activityName,
            during: schedule,
            events: [eventName: event]
        )
    }

    static func stop() {
        DeviceActivityCenter().stopMonitoring([activityName])
    }
}
