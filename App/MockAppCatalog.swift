import SwiftUI

struct MockApp: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let symbol: String
    let tint: MockAppTint
    let assetName: String
}

enum MockAppTint: String, Codable {
    case red, orange, pink, purple, blue, green, indigo, yellow

    var color: Color {
        switch self {
        case .red: .red
        case .orange: .orange
        case .pink: .pink
        case .purple: .purple
        case .blue: .blue
        case .green: .green
        case .indigo: .indigo
        case .yellow: .yellow
        }
    }
}

enum MockAppCatalog {
    static let all: [MockApp] = [
        MockApp(id: "instagram", name: "Instagram", symbol: "camera.fill", tint: .pink, assetName: "AppLogos/instagram"),
        MockApp(id: "tiktok", name: "TikTok", symbol: "music.note", tint: .purple, assetName: "AppLogos/tiktok"),
        MockApp(id: "youtube", name: "YouTube", symbol: "play.rectangle.fill", tint: .red, assetName: "AppLogos/youtube"),
        MockApp(id: "reddit", name: "Reddit", symbol: "circle.hexagongrid.fill", tint: .orange, assetName: "AppLogos/reddit"),
        MockApp(id: "snapchat", name: "Snapchat", symbol: "bolt.fill", tint: .yellow, assetName: "AppLogos/snapchat"),
        MockApp(id: "netflix", name: "Netflix", symbol: "film.fill", tint: .red, assetName: "AppLogos/netflix"),
        MockApp(id: "discord", name: "Discord", symbol: "gamecontroller.fill", tint: .indigo, assetName: "AppLogos/discord"),
    ]
}
