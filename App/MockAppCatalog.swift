import SwiftUI

struct MockApp: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let symbol: String
    let tint: MockAppTint
}

enum MockAppTint: String, Codable {
    case red, orange, pink, purple, blue, green, indigo

    var color: Color {
        switch self {
        case .red: .red
        case .orange: .orange
        case .pink: .pink
        case .purple: .purple
        case .blue: .blue
        case .green: .green
        case .indigo: .indigo
        }
    }
}

enum MockAppCatalog {
    static let all: [MockApp] = [
        MockApp(id: "instagram", name: "Instagram", symbol: "camera.fill", tint: .pink),
        MockApp(id: "tiktok", name: "TikTok", symbol: "music.note", tint: .purple),
        MockApp(id: "youtube", name: "YouTube", symbol: "play.rectangle.fill", tint: .red),
        MockApp(id: "twitter", name: "X / Twitter", symbol: "bubble.left.fill", tint: .blue),
        MockApp(id: "reddit", name: "Reddit", symbol: "circle.hexagongrid.fill", tint: .orange),
        MockApp(id: "safari", name: "Safari", symbol: "safari.fill", tint: .indigo),
        MockApp(id: "netflix", name: "Netflix", symbol: "film.fill", tint: .red),
        MockApp(id: "games", name: "Games", symbol: "gamecontroller.fill", tint: .green),
    ]
}
