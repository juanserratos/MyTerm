import Combine
import Foundation

@MainActor
final class NotesStore: ObservableObject {
    @Published private(set) var notes: [Note] = []
    @Published var selectedNoteID: Note.ID?

    private let storageURL: URL
    private var cancellables: Set<AnyCancellable> = []

    init(fileManager: FileManager = .default) {
        let support = try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        storageURL = support?.appending(path: "MyTermNotes/notes.json") ?? URL(fileURLWithPath: NSTemporaryDirectory()).appending(path: "MyTermNotes/notes.json")

        Task {
            await load()
        }

        $notes
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] notes in
                Task { await self?.persist(notes: notes) }
            }
            .store(in: &cancellables)

        $selectedNoteID
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.persist(notes: self.notes) }
            }
            .store(in: &cancellables)
    }

    func createNote() {
        var note = Note()
        note.title = "New Note"
        note.content = ""
        note.tint = NoteTint.allCases.randomElement() ?? .vercelSand
        note.createdAt = Date()
        note.updatedAt = Date()
        notes.insert(note, at: 0)
        selectedNoteID = note.id
        reorderNotes()
    }

    func delete(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        if selectedNoteID == note.id {
            selectedNoteID = notes.first?.id
        }
    }

    func update(note: Note, title: String, content: String) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].title = title
        notes[index].content = content
        notes[index].updatedAt = Date()
        selectedNoteID = note.id
        reorderNotes()
    }

    func updateTint(for note: Note, tint: NoteTint) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].tint = tint
        notes[index].updatedAt = Date()
        selectedNoteID = note.id
        reorderNotes()
    }

    func select(_ note: Note?) {
        selectedNoteID = note?.id
    }

    private func load() async {
        do {
            let data = try Data(contentsOf: storageURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let collection = try decoder.decode(NoteCollection.self, from: data)
            notes = collection.notes
            selectedNoteID = collection.selectedID ?? collection.notes.first?.id
        } catch {
            notes = []
            selectedNoteID = nil
        }

        if notes.isEmpty {
            createNote()
        }

        reorderNotes()
    }

    private func persist(notes: [Note]) async {
        let collection = NoteCollection(notes: notes, selectedID: selectedNoteID)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(collection)
            try FileManager.default.createDirectory(at: storageURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            NSLog("Failed to persist notes: \(error.localizedDescription)")
        }
    }

    private func reorderNotes() {
        notes.sort { lhs, rhs in
            if lhs.updatedAt == rhs.updatedAt {
                return lhs.createdAt > rhs.createdAt
            }
            return lhs.updatedAt > rhs.updatedAt
        }
        if let selectedNoteID,
           let selectedIndex = notes.firstIndex(where: { $0.id == selectedNoteID }) {
            selectedNoteID = notes[selectedIndex].id
        }
    }
}
