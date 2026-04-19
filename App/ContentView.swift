import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Today", systemImage: "timer") }
            FriendsView()
                .tabItem { Label("Accountability", systemImage: "person.2.fill") }
        }
        .tint(.indigo)
    }
}
