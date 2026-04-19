import SwiftUI

struct AddFriendSheet: View {
    var onAdd: (Friend) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var emoji = "🙂"

    private let emojiChoices = [
        "🙂", "😎", "🤓", "🥳", "😇", "🫶",
        "🐱", "🐶", "🦊", "🐼", "🐸", "🦄",
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Friend's name", text: $name)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                }
                Section("Avatar") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 6),
                        spacing: 10
                    ) {
                        ForEach(emojiChoices, id: \.self) { choice in
                            Button {
                                emoji = choice
                            } label: {
                                Text(choice)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle().fill(
                                            emoji == choice
                                                ? Color.accentColor.opacity(0.25)
                                                : Color(.tertiarySystemGroupedBackground)
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Add friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onAdd(Friend(name: trimmed, emoji: emoji))
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
