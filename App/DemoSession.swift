import Foundation
import Observation

@MainActor
@Observable
final class DemoSession {
    private(set) var simulatedMinutesUsed: Int = 0
    private(set) var isRunning: Bool = false
    var settings: LimitSettings

    private var timer: Timer?
    private var lastLoggedOverMinutes: Int = 0

    init(settings: LimitSettings) {
        self.settings = settings
    }

    var minutesOver: Int { max(0, simulatedMinutesUsed - settings.dailyMinutes) }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        lastLoggedOverMinutes = minutesOver
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func reset() {
        stop()
        simulatedMinutesUsed = 0
        lastLoggedOverMinutes = 0
    }

    private func tick() {
        simulatedMinutesUsed += 1
        let current = minutesOver
        guard current > lastLoggedOverMinutes else { return }
        let delta = current - lastLoggedOverMinutes
        OverageLedger.append(OverageEvent(
            minutesOver: delta,
            centsOwed: delta * settings.centsPerMinuteOver
        ))
        lastLoggedOverMinutes = current
    }
}
