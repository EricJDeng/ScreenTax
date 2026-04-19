import SwiftUI

struct AppSelectionView: View {
    @Binding var watchedAppIds: Set<String>

    var body: some View {
        ForEach(MockAppCatalog.all) { app in
            Toggle(isOn: binding(for: app)) {
                Label {
                    Text(app.name)
                } icon: {
                    Image(systemName: app.symbol).foregroundStyle(app.tint.color)
                }
            }
        }
    }

    private func binding(for app: MockApp) -> Binding<Bool> {
        Binding(
            get: { watchedAppIds.contains(app.id) },
            set: { isOn in
                if isOn { watchedAppIds.insert(app.id) }
                else { watchedAppIds.remove(app.id) }
            }
        )
    }
}
