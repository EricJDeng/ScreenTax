import SwiftUI

struct HomeView: View {
    @State private var settings: LimitSettings = LimitSettingsStore.load()
    @State private var payout: PayoutSettings = PayoutSettingsStore.load()
    @State private var session: DemoSession?
    @State private var ledgerTotal: Int = OverageLedger.totalCentsOwed()
    @State private var showingAppPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    owedCard
                    simulationCard
                    limitCard
                    appsCard
                    payoutSummary
                    if ledgerTotal > 0 {
                        clearLedgerButton
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("ScreenTax")
        }
        .onChange(of: settings) { _, new in
            LimitSettingsStore.save(new)
            session?.settings = new
        }
        .onChange(of: session?.simulatedMinutesUsed) { _, _ in
            ledgerTotal = OverageLedger.totalCentsOwed()
        }
        .onAppear {
            payout = PayoutSettingsStore.load()
            ledgerTotal = OverageLedger.totalCentsOwed()
        }
        .sheet(isPresented: $showingAppPicker) {
            NavigationStack {
                Form {
                    Section {
                        AppSelectionView(watchedAppIds: $settings.watchedAppIds)
                    } footer: {
                        Text("Only these apps count toward your daily limit.")
                    }
                }
                .navigationTitle("Watched apps")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showingAppPicker = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var owedCard: some View {
        VStack(spacing: 6) {
            Text("Owed so far")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(formatCents(ledgerTotal))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(ledgerTotal > 0 ? Color.red : Color.primary)
                .contentTransition(.numericText())
                .animation(.snappy, value: ledgerTotal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .cardBackground()
    }

    private var simulationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Simulation", systemImage: "timer")
                    .font(.headline)
                Spacer()
                if session?.isRunning == true {
                    liveBadge
                }
            }

            if let session, session.isRunning {
                runningControls(session)
            } else {
                idleControls
            }
        }
        .padding()
        .cardBackground()
    }

    private var liveBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.green)
                .frame(width: 7, height: 7)
                .modifier(PulseEffect())
            Text("LIVE")
                .font(.caption2.bold())
                .foregroundStyle(.green)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Capsule().fill(Color.green.opacity(0.12)))
    }

    private func runningControls(_ session: DemoSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ProgressView(
                value: min(Double(session.simulatedMinutesUsed), Double(settings.dailyMinutes)),
                total: Double(settings.dailyMinutes)
            )
            .tint(session.minutesOver > 0 ? .red : .accentColor)

            HStack {
                Text("\(session.simulatedMinutesUsed) / \(settings.dailyMinutes) min")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                if session.minutesOver > 0 {
                    Text("+\(session.minutesOver) over")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.red)
                }
            }

            Button(role: .destructive) {
                session.stop()
                self.session = nil
            } label: {
                Label("Stop simulation", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
    }

    private var idleControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Each real second counts as one simulated minute of screen time.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button {
                startSession()
            } label: {
                Label("Start simulation", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .disabled(settings.watchedAppIds.isEmpty)
        }
    }

    private var limitCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Limits", systemImage: "hourglass")
                .font(.headline)

            Stepper(value: $settings.dailyMinutes, in: 1...600, step: 5) {
                HStack {
                    Text("Daily limit")
                    Spacer()
                    Text("\(settings.dailyMinutes) min")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            Divider()
            Stepper(value: $settings.centsPerMinuteOver, in: 1...500, step: 5) {
                HStack {
                    Text("Per extra minute")
                    Spacer()
                    Text(formatCents(settings.centsPerMinuteOver))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .padding()
        .cardBackground()
    }

    private var appsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Watched apps", systemImage: "app.badge")
                    .font(.headline)
                Spacer()
                Button { showingAppPicker = true } label: {
                    Text(settings.watchedAppIds.isEmpty ? "Pick" : "Edit")
                        .font(.subheadline.weight(.medium))
                }
            }

            if watchedApps.isEmpty {
                HStack {
                    Image(systemName: "app.dashed")
                        .foregroundStyle(.tertiary)
                    Text("Pick at least one app to start")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 72, maximum: 88))],
                    spacing: 14
                ) {
                    ForEach(watchedApps) { app in
                        VStack(spacing: 6) {
                            Image(systemName: app.symbol)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 52, height: 52)
                                .background(app.tint.color.gradient)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                            Text(app.name)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding()
        .cardBackground()
    }

    private var payoutSummary: some View {
        HStack(spacing: 12) {
            Image(systemName: payout.mode == .charity ? "heart.fill" : "person.2.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background((payout.mode == .charity ? Color.pink : Color.indigo).gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(payoutTitle)
                    .font(.subheadline.weight(.semibold))
                Text(payoutSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding()
        .cardBackground()
    }

    private var payoutTitle: String {
        switch payout.mode {
        case .friends:
            return payout.friends.isEmpty
                ? "Add your accountability group"
                : "Split with \(payout.friends.count) friend\(payout.friends.count == 1 ? "" : "s")"
        case .charity:
            return CharityCatalog.find(id: payout.selectedCharityId)?.name ?? "Pick a charity"
        }
    }

    private var payoutSubtitle: String {
        switch payout.mode {
        case .friends: "Friends mode"
        case .charity: "Charity mode"
        }
    }

    private var clearLedgerButton: some View {
        Button(role: .destructive) {
            OverageLedger.clear()
            ledgerTotal = 0
        } label: {
            Label("Clear ledger", systemImage: "trash")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .padding(.top, 4)
    }

    private var watchedApps: [MockApp] {
        MockAppCatalog.all.filter { settings.watchedAppIds.contains($0.id) }
    }

    private func startSession() {
        let newSession = DemoSession(settings: settings)
        newSession.start()
        session = newSession
    }

    private func formatCents(_ cents: Int) -> String {
        let dollars = Double(cents) / 100
        return dollars.formatted(.currency(code: "USD"))
    }
}

private struct PulseEffect: ViewModifier {
    @State private var on = false
    func body(content: Content) -> some View {
        content
            .opacity(on ? 0.35 : 1.0)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: on)
            .onAppear { on = true }
    }
}
