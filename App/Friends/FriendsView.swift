import SwiftUI

struct FriendsView: View {
    @State private var payout: PayoutSettings = PayoutSettingsStore.load()
    @State private var showingAddFriend = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    modeCard
                    if payout.mode == .friends {
                        friendsCard
                    } else {
                        charityCard
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Accountability")
        }
        .onChange(of: payout) { _, new in
            PayoutSettingsStore.save(new)
        }
        .sheet(isPresented: $showingAddFriend) {
            AddFriendSheet { friend in
                payout.friends.append(friend)
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var modeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Where does your money go?")
                .font(.headline)
            Picker("Mode", selection: $payout.mode) {
                ForEach(PayoutMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            Text(payout.mode.explanation)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .cardBackground()
    }

    private var friendsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label("Group", systemImage: "person.2.fill")
                    .font(.headline)
                Spacer()
                Button {
                    showingAddFriend = true
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.medium))
                }
            }
            .padding(.bottom, 8)

            if payout.friends.isEmpty {
                emptyFriendsState
            } else {
                ForEach(Array(payout.friends.enumerated()), id: \.element.id) { index, friend in
                    friendRow(friend)
                    if index < payout.friends.count - 1 {
                        Divider().padding(.leading, 52)
                    }
                }
            }
        }
        .padding()
        .cardBackground()
    }

    private var emptyFriendsState: some View {
        VStack(spacing: 6) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            Text("No friends yet")
                .font(.subheadline.weight(.medium))
            Text("Add someone to split your overage with.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private func friendRow(_ friend: Friend) -> some View {
        HStack(spacing: 12) {
            Text(friend.emoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color(.tertiarySystemGroupedBackground)))
            Text(friend.name)
                .font(.body)
            Spacer()
            Button {
                payout.friends.removeAll { $0.id == friend.id }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }

    private var charityCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Label("Choose a cause", systemImage: "heart.fill")
                .font(.headline)
                .padding(.bottom, 12)

            ForEach(Array(CharityCatalog.all.enumerated()), id: \.element.id) { index, charity in
                charityRow(charity)
                if index < CharityCatalog.all.count - 1 {
                    Divider().padding(.leading, 52)
                }
            }
        }
        .padding()
        .cardBackground()
    }

    private func charityRow(_ charity: Charity) -> some View {
        Button {
            withAnimation(.snappy) { payout.selectedCharityId = charity.id }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: charity.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(charity.tint.color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text(charity.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(charity.tagline)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: payout.selectedCharityId == charity.id
                      ? "checkmark.circle.fill"
                      : "circle")
                    .font(.title3)
                    .foregroundStyle(
                        payout.selectedCharityId == charity.id
                            ? AnyShapeStyle(Color.green)
                            : AnyShapeStyle(.tertiary)
                    )
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

extension View {
    func cardBackground() -> some View { modifier(CardBackground()) }
}
