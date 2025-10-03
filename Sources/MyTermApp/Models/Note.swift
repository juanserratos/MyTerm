import Foundation

struct Note: Identifiable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, content: String, updatedAt: Date = .now) {
        self.id = id
        self.title = title
        self.content = content
        self.updatedAt = updatedAt
    }

    var previewLine: String {
        let trimmed = content
            .split(whereSeparator: { $0.isNewline })
            .first
            .map(String.init)
            ?? ""
        return trimmed.isEmpty ? "New note" : trimmed
    }

    static func title(from content: String, fallback: String) -> String {
        let firstLine = content
            .split(whereSeparator: { $0.isNewline })
            .first
            .map(String.init)
            ?? ""
        let trimmed = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}
