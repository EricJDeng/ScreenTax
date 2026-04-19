import FamilyControls
import SwiftUI

struct AppSelectionView: View {
    @Binding var selection: FamilyActivitySelection
    @State private var isPickerPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(summary).foregroundStyle(.secondary)
            Button("Choose apps…") { isPickerPresented = true }
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
    }

    private var summary: String {
        let count = selection.applicationTokens.count
            + selection.categoryTokens.count
            + selection.webDomainTokens.count
        return count == 0 ? "None selected" : "\(count) item(s) selected"
    }
}
