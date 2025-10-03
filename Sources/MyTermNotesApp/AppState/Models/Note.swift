import Foundation
import SwiftUI

struct Note: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var tint: NoteTint

    init(id: UUID = UUID(), title: String = "", content: String = "", createdAt: Date = .init(), updatedAt: Date = .init(), tint: NoteTint = .vercelSand) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tint = tint
    }

    var preview: String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Add your thoughts…" }
        return String(trimmed.prefix(120))
    }
}

struct NoteCollection: Codable {
    var notes: [Note]
    var selectedID: UUID?
}

enum NoteTint: String, CaseIterable, Codable, Identifiable {
    case vercelSand
    case vercelIris
    case vercelMint
    case vercelSun
    case vercelOrange

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .vercelSand:
            return Color(red: 0.22, green: 0.22, blue: 0.24)
        case .vercelIris:
            return Color(red: 0.49, green: 0.42, blue: 0.93)
        case .vercelMint:
            return Color(red: 0.09, green: 0.74, blue: 0.63)
        case .vercelSun:
            return Color(red: 0.97, green: 0.73, blue: 0.29)
        case .vercelOrange:
            return Color(red: 0.99, green: 0.44, blue: 0.18)
        }
    }

    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [color.opacity(0.95), color.opacity(0.65)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
