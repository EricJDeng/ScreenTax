import DeviceActivity
import Foundation

final class ScreenTaxMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)
        guard event == DeviceActivityEvent.Name("ScreenTax.LimitReached") else { return }

        let settings = LimitSettingsStore.load()
        let overage = OverageEvent(
            minutesOver: 1,
            centsOwed: settings.centsPerMinuteOver
        )
        OverageLedger.append(overage)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
    }
}
