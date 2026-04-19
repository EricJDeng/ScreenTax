import Foundation

struct OverageEvent: Codable, Identifiable, Equatable {
    let id: UUID
    let occurredAt: Date
    let minutesOver: Int
    let centsOwed: Int

    init(id: UUID = UUID(), occurredAt: Date = Date(), minutesOver: Int, centsOwed: Int) {
        self.id = id
        self.occurredAt = occurredAt
        self.minutesOver = minutesOver
        self.centsOwed = centsOwed
    }
}

enum OverageLedger {
    private static let key = "overageEvents"

    static func all() -> [OverageEvent] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let events = try? JSONDecoder().decode([OverageEvent].self, from: data)
        else { return [] }
        return events
    }

    static func append(_ event: OverageEvent) {
        var events = all()
        events.append(event)
        guard let data = try? JSONEncoder().encode(events) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func totalCentsOwed() -> Int {
        all().reduce(0) { $0 + $1.centsOwed }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
