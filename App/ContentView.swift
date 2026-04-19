import FamilyControls
import SwiftUI

struct ContentView: View {
    @State private var authorization = AuthorizationModel()
    @State private var settings: LimitSettings = LimitSettingsStore.load()
    @State private var isMonitoring = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                authorizationSection
                if authorization.state == .approved {
                    selectionSection
                    limitSection
                    monitoringSection
                    ledgerSection
                }
                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("ScreenTax")
        }
        .task { await authorization.requestIfNeeded() }
        .onChange(of: settings) { _, new in LimitSettingsStore.save(new) }
    }

    private var authorizationSection: some View {
        Section("Family Controls") {
            switch authorization.state {
            case .unknown:
                Button("Request permission") {
                    Task { await authorization.requestAuthorization() }
                }
            case .approved:
                Label("Authorized", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            case .denied:
                Text("Permission denied. Enable Screen Time access in Settings.")
                    .foregroundStyle(.red)
            }
        }
    }

    private var selectionSection: some View {
        Section("Watched apps") {
            AppSelectionView(selection: $settings.selection)
        }
    }

    private var limitSection: some View {
        Section("Daily limit") {
            Stepper(value: $settings.dailyMinutes, in: 5...600, step: 5) {
                Text("\(settings.dailyMinutes) min/day")
            }
            Stepper(value: $settings.centsPerMinuteOver, in: 1...500, step: 1) {
                Text("\(formatCents(settings.centsPerMinuteOver)) per extra minute")
            }
        }
    }

    private var monitoringSection: some View {
        Section {
            Button(isMonitoring ? "Stop monitoring" : "Start monitoring") {
                toggleMonitoring()
            }
            .disabled(selectionIsEmpty)
        } footer: {
            if selectionIsEmpty {
                Text("Select at least one app or category first.")
            }
        }
    }

    private var ledgerSection: some View {
        Section("Owed so far") {
            Text(formatCents(OverageLedger.totalCentsOwed()))
                .font(.title2.monospacedDigit())
        }
    }

    private var selectionIsEmpty: Bool {
        settings.selection.applicationTokens.isEmpty
            && settings.selection.categoryTokens.isEmpty
            && settings.selection.webDomainTokens.isEmpty
    }

    private func toggleMonitoring() {
        errorMessage = nil
        do {
            if isMonitoring {
                MonitoringController.stop()
                isMonitoring = false
            } else {
                try MonitoringController.start(with: settings)
                isMonitoring = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func formatCents(_ cents: Int) -> String {
        let dollars = Double(cents) / 100
        return dollars.formatted(.currency(code: "USD"))
    }
}
