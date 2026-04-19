import SwiftUI

struct Charity: Identifiable, Hashable {
    let id: String
    let name: String
    let tagline: String
    let symbol: String
    let tint: MockAppTint
}

enum CharityCatalog {
    static let all: [Charity] = [
        Charity(
            id: "redcross",
            name: "American Red Cross",
            tagline: "Disaster relief and emergency response",
            symbol: "cross.case.fill",
            tint: .red
        ),
        Charity(
            id: "dww",
            name: "Doctors Without Borders",
            tagline: "Medical humanitarian aid worldwide",
            symbol: "stethoscope",
            tint: .blue
        ),
        Charity(
            id: "unicef",
            name: "UNICEF",
            tagline: "Protecting children in need",
            symbol: "figure.2.and.child.holdinghands",
            tint: .indigo
        ),
        Charity(
            id: "wwf",
            name: "World Wildlife Fund",
            tagline: "Protecting wildlife and habitats",
            symbol: "leaf.fill",
            tint: .green
        ),
        Charity(
            id: "feedingamerica",
            name: "Feeding America",
            tagline: "Fighting hunger across the U.S.",
            symbol: "fork.knife",
            tint: .orange
        ),
        Charity(
            id: "teachforall",
            name: "Teach For All",
            tagline: "Education access for every child",
            symbol: "book.fill",
            tint: .purple
        ),
    ]

    static func find(id: String?) -> Charity? {
        guard let id else { return nil }
        return all.first { $0.id == id }
    }
}
