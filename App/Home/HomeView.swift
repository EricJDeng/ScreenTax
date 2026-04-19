import SwiftUI

struct HomeView: View {
    @State private var settings: LimitSettings = LimitSettingsStore.load()
    @State private var payout: PayoutSettings = PayoutSettingsStore.load()
    @State private var session: DemoSession?
    @State private var ledgerTotal: Int = OverageLedger.totalCentsOwed()
    @State private var showingAppPicker = false
    @State private var showingSettleConfirmation = false
    @State private var showingSettleSuccess = false
    @State private var lastSettledCents = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    heroCard
                    if ledgerTotal > 0 {
                        settleCard
                    }
                    settingsCard
                    appsCard
                    payoutRow
                    if ledgerTotal > 0 {
                        clearLedgerButton
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
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
        .sheet(isPresented: $showingAppPicker) { appPickerSheet }
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(spacing: 18) {
            if let session, session.isRunning {
                runningHero(session)
            } else {
                idleHero
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(heroBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(
            color: session?.isRunning == true
                ? Color.indigo.opacity(0.22)
                : Color.black.opacity(0.04),
            radius: 18, x: 0, y: 8
        )
        .animation(.snappy, value: session?.isRunning)
        .animation(.snappy, value: session?.minutesOver ?? 0 > 0)
    }

    @ViewBuilder
    private var heroBackground: some View {
        if session?.isRunning == true {
            LinearGradient(
                colors: (session?.minutesOver ?? 0) > 0
                    ? [Color.red, Color.orange]
                    : [Color.indigo, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color(.secondarySystemGroupedBackground)
        }
    }

    private var idleHero: some View {
        VStack(spacing: 14) {
            Text("OWED SO FAR")
                .font(.caption.bold())
                .tracking(1.6)
                .foregroundStyle(.secondary)

            Text(formatCents(ledgerTotal))
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(ledgerTotal > 0 ? Color.red : Color.primary)
                .contentTransition(.numericText())
                .animation(.snappy, value: ledgerTotal)

            if settings.watchedAppIds.isEmpty {
                Text("Pick some apps below to get started")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }

            Button {
                startSession()
            } label: {
                Label("Start tracking", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.indigo)
            .disabled(settings.watchedAppIds.isEmpty)
            .padding(.top, 6)
        }
    }

    private func runningHero(_ session: DemoSession) -> some View {
        let progress = min(Double(session.simulatedMinutesUsed) / Double(max(settings.dailyMinutes, 1)), 1.0)
        let sessionCents = session.minutesOver * settings.centsPerMinuteOver
        let isOver = session.minutesOver > 0
        return VStack(spacing: 18) {
            HStack {
                liveBadge
                Spacer()
                Text(isOver ? "OVER LIMIT" : "TRACKING")
                    .font(.caption2.bold())
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.9))
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.18), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.25), value: progress)

                VStack(spacing: 2) {
                    Text(formatCents(sessionCents))
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text(isOver
                        ? "+\(session.minutesOver) min over"
                        : "\(session.simulatedMinutesUsed) / \(settings.dailyMinutes) min")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .monospacedDigit()
                }
            }
            .frame(width: 220, height: 220)
            .padding(.vertical, 4)

            Button {
                session.stop()
                self.session = nil
            } label: {
                Label("Stop tracking", systemImage: "stop.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.white.opacity(0.22))
        }
    }

    private var liveBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.white)
                .frame(width: 7, height: 7)
                .modifier(PulseEffect())
            Text("LIVE")
                .font(.caption2.bold())
                .tracking(1.2)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.white.opacity(0.22)))
    }

    // MARK: - Settle

    private var settleCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(settleHeadline)
                        .font(.caption.bold())
                        .tracking(1.4)
                        .foregroundStyle(.secondary)
                    Text(formatCents(ledgerTotal))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }
                Spacer()
                Image(systemName: payout.mode == .friends ? "paperplane.fill" : "heart.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(settleTint.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            HStack(spacing: 6) {
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                Text(settleDestination)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Spacer()
            }

            if payout.mode == .friends, !payout.friends.isEmpty {
                Text("Each friend gets \(formatCents(perFriendCents))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Button {
                showingSettleConfirmation = true
            } label: {
                Label(
                    settleButtonTitle,
                    systemImage: payout.mode == .friends ? "paperplane.fill" : "heart.circle.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(settleTint)
            .disabled(!canSettle)

            if !canSettle {
                Text(
                    payout.mode == .friends
                        ? "Add someone in Accountability to pay."
                        : "Pick a charity in Accountability to donate."
                )
                .font(.caption)
                .foregroundStyle(.orange)
            }
        }
        .padding(18)
        .cardBackground()
        .confirmationDialog(
            "Settle \(formatCents(ledgerTotal))?",
            isPresented: $showingSettleConfirmation,
            titleVisibility: .visible
        ) {
            Button(settleButtonTitle) { settlePayment() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(settleConfirmationMessage)
        }
        .alert(settleSuccessTitle, isPresented: $showingSettleSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(settleSuccessMessage)
        }
    }

    private var settleHeadline: String {
        payout.mode == .friends ? "TIME TO PAY UP" : "TIME TO GIVE BACK"
    }

    private var settleTint: Color {
        payout.mode == .friends ? .indigo : .pink
    }

    private var settleDestination: String {
        switch payout.mode {
        case .friends:
            if payout.friends.isEmpty { return "No friends in your group yet" }
            let names = payout.friends.prefix(3).map(\.name).joined(separator: ", ")
            let rest = payout.friends.count > 3 ? " +\(payout.friends.count - 3) more" : ""
            return names + rest
        case .charity:
            return CharityCatalog.find(id: payout.selectedCharityId)?.name ?? "No charity selected"
        }
    }

    private var settleButtonTitle: String {
        switch payout.mode {
        case .friends: "Pay friends now"
        case .charity: "Donate now"
        }
    }

    private var perFriendCents: Int {
        guard !payout.friends.isEmpty else { return 0 }
        return ledgerTotal / payout.friends.count
    }

    private var canSettle: Bool {
        switch payout.mode {
        case .friends: !payout.friends.isEmpty
        case .charity: payout.selectedCharityId != nil
        }
    }

    private var settleConfirmationMessage: String {
        switch payout.mode {
        case .friends:
            let count = payout.friends.count
            return "Sending \(formatCents(perFriendCents)) to each of \(count) friend\(count == 1 ? "" : "s")."
        case .charity:
            let name = CharityCatalog.find(id: payout.selectedCharityId)?.name ?? "the selected cause"
            return "Donating \(formatCents(ledgerTotal)) to \(name)."
        }
    }

    private var settleSuccessTitle: String {
        payout.mode == .friends ? "Paid" : "Donated"
    }

    private var settleSuccessMessage: String {
        switch payout.mode {
        case .friends:
            return "Sent \(formatCents(lastSettledCents)) to your accountability group."
        case .charity:
            let name = CharityCatalog.find(id: payout.selectedCharityId)?.name ?? "your cause"
            return "\(formatCents(lastSettledCents)) is on its way to \(name). Thanks for giving back."
        }
    }

    private func settlePayment() {
        lastSettledCents = ledgerTotal
        withAnimation(.snappy) {
            OverageLedger.clear()
            ledgerTotal = 0
        }
        showingSettleSuccess = true
    }

    // MARK: - Settings

    private var settingsCard: some View {
        VStack(spacing: 0) {
            settingsRow(
                icon: "hourglass",
                tint: .blue,
                title: "Daily limit",
                value: "\(settings.dailyMinutes) min"
            ) {
                Stepper("", value: $settings.dailyMinutes, in: 1...600, step: 5)
                    .labelsHidden()
            }
            Divider().padding(.leading, 60)
            settingsRow(
                icon: "dollarsign.circle.fill",
                tint: .green,
                title: "Rate over limit",
                value: "\(formatCents(settings.centsPerMinuteOver)) / min"
            ) {
                Stepper("", value: $settings.centsPerMinuteOver, in: 1...500, step: 5)
                    .labelsHidden()
            }
        }
        .padding(12)
        .cardBackground()
    }

    private func settingsRow<Control: View>(
        icon: String,
        tint: Color,
        title: String,
        value: String,
        @ViewBuilder control: () -> Control
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(tint.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.subheadline.weight(.medium))
                Text(value).font(.caption).foregroundStyle(.secondary).monospacedDigit()
            }
            Spacer()
            control()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
    }

    // MARK: - Apps

    private var appsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Watched apps")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    showingAppPicker = true
                } label: {
                    Text(settings.watchedAppIds.isEmpty ? "Add" : "Edit")
                        .font(.subheadline.weight(.semibold))
                }
            }

            if watchedApps.isEmpty {
                Button { showingAppPicker = true } label: {
                    HStack {
                        Image(systemName: "plus.app")
                            .font(.title3)
                            .foregroundStyle(.indigo)
                        Text("Choose apps to watch")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 4)
                }
                .buttonStyle(.plain)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(watchedApps) { app in
                            VStack(spacing: 6) {
                                AppIconView(app: app, size: 54)
                                Text(app.name)
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .frame(width: 64)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(16)
        .cardBackground()
    }

    // MARK: - Payout

    private var payoutRow: some View {
        HStack(spacing: 12) {
            Image(systemName: payout.mode == .charity ? "heart.fill" : "person.2.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background((payout.mode == .charity ? Color.pink : Color.indigo).gradient)
                .clipShape(RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 1) {
                Text(payoutTitle)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(payoutSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
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
        case .friends: "Friends mode · tap Accountability"
        case .charity: "Charity mode · tap Accountability"
        }
    }

    // MARK: - Footer

    private var clearLedgerButton: some View {
        Button(role: .destructive) {
            withAnimation(.snappy) {
                OverageLedger.clear()
                ledgerTotal = 0
            }
        } label: {
            Label("Clear ledger", systemImage: "trash")
                .font(.subheadline.weight(.medium))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.red)
        .padding(.top, 4)
    }

    // MARK: - App picker sheet

    private var appPickerSheet: some View {
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

    // MARK: - Helpers

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
