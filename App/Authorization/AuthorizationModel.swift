import FamilyControls
import Observation

@MainActor
@Observable
final class AuthorizationModel {
    enum State {
        case unknown, approved, denied
    }

    var state: State = .unknown

    init() { refresh() }

    func requestIfNeeded() async {
        refresh()
        if state == .unknown { await requestAuthorization() }
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            refresh()
        } catch {
            state = .denied
        }
    }

    private func refresh() {
        switch AuthorizationCenter.shared.authorizationStatus {
        case .approved: state = .approved
        case .denied: state = .denied
        case .notDetermined: state = .unknown
        @unknown default: state = .unknown
        }
    }
}
