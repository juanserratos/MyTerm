import Foundation
import SwiftUI

@MainActor
final class NotesStore: ObservableObject {
    @Published var notes: [Note]
    @Published var selectedNoteID: UUID?
    @Published var searchText: String = ""

    @Published var latexMacroDefinitions: String {
        didSet {
            UserDefaults.standard.set(latexMacroDefinitions, forKey: Self.macroDefaultsKey)
        }
    }

    @Published var latexEnvironmentDefinitions: String {
        didSet {
            UserDefaults.standard.set(latexEnvironmentDefinitions, forKey: Self.environmentDefaultsKey)
        }
    }

    var latexPreamble: String {
        [latexMacroDefinitions, latexEnvironmentDefinitions]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n\n")
    }

    init() {
        let defaults = UserDefaults.standard

        latexMacroDefinitions = defaults.string(forKey: Self.macroDefaultsKey) ?? Self.defaultMacros
        latexEnvironmentDefinitions = defaults.string(forKey: Self.environmentDefaultsKey) ?? Self.defaultEnvironments

        let sampleContent = """
Agenda

Sketch the roadmap with inline math $f(x) = x^2 + 1$ and displayed derivations:

$$\\begin{align*}
F(n) &= F(n-1) + F(n-2) \\\\
\\Phi &= \\frac{1 + \\sqrt{5}}{2}
\\end{align*}$$

Operators declared in settings such as \\Sym should render everywhere.
"""

        let first = Note(title: "Studio Kickoff", content: sampleContent)
        let second = Note(
            title: "Research Journal",
            content: """
Remember to declare \\newcommand{\\RR}{\\mathbb{R}} inside the LaTeX palette so $\\RR$ renders as the reals.

Block matrices like $\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}$ stay crisp, and theorem environments from settings appear boxed.
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

private extension NotesStore {
    static let macroDefaultsKey = "LatexMacroDefaults"
    static let environmentDefaultsKey = "LatexEnvironmentDefaults"

    static let defaultMacros: String = """
% Global macros
\\newcommand{\\RR}{\\mathbb{R}}
\\newcommand{\\QQ}{\\mathbb{Q}}
\\newcommand{\\ZZ}{\\mathbb{Z}}
\\newcommand{\\NN}{\\mathbb{N}}
\\newcommand{\\CC}{\\mathbb{C}}
\\newcommand{\\EE}{\\mathbb{E}}
\\DeclareMathOperator{\\Var}{Var}
\\DeclareMathOperator{\\Cov}{Cov}
\\DeclareMathOperator{\\Sym}{Sym}
"""

    static let defaultEnvironments: String = """
% Custom blocks (example)
% \\newenvironment{proof}{\\begin{aligned}}{\\end{aligned}}
"""
}
