import Foundation
import SwiftUI

@MainActor
final class NotesStore: ObservableObject {
    @Published var notes: [Note]
    @Published var selectedNoteID: UUID?
    @Published var searchText: String = ""

    init() {
        let sampleContent = """
Meeting Notes

Planning the next release with inline math $f(x) = x^2 + 1$ and a displayed block:

$$\\begin{align*}
F(n) &= F(n-1) + F(n-2)\\\\
\\Phi &= \\frac{1 + \\sqrt{5}}{2}
\\end{align*}$$

We can also declare operators using \\DeclareMathOperator{\\Sym}{Sym}.
"""

        let first = Note(title: "Team Sync", content: sampleContent)
        let second = Note(
            title: "Research",
            content: """
Remember to define \\newcommand{\\RR}{\\mathbb{R}} before using it.

Then $\\RR$ renders automatically and matrices like $\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}$ look great.
"""
        )
        notes = [first, second]
        selectedNoteID = notes.first?.id
    }

    func binding(for id: UUID?) -> Binding<Note>? {
        guard let id, let index = notes.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        return Binding(
            get: { self.notes[index] },
            set: { newValue in
                self.notes[index] = newValue
            }
        )
    }

    func createNote() {
        let newNote = Note(title: "New Note", content: "")
        notes.insert(newNote, at: 0)
        selectedNoteID = newNote.id
    }

    func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        if let currentID = selectedNoteID, !notes.contains(where: { $0.id == currentID }) {
            selectedNoteID = notes.first?.id
        }
    }
    func deleteNotes(withIDs ids: [UUID]) {
        guard !ids.isEmpty else { return }
        notes.removeAll { ids.contains($0.id) }
        if let currentID = selectedNoteID, !notes.contains(where: { $0.id == currentID }) {
            selectedNoteID = notes.first?.id
        }
    }

}
