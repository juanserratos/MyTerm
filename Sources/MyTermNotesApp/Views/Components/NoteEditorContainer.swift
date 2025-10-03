import SwiftUI

struct NoteEditorContainer: View {
    @EnvironmentObject private var notesStore: NotesStore
    @EnvironmentObject private var settingsStore: LatexSettingsStore

    @State private var title: String
    @State private var content: String
    private let noteID: Note.ID

    init(note: Note) {
        self.noteID = note.id
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let note = currentNote {
                HStack(spacing: 16) {
                TextField("Title", text: $title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .textFieldStyle(.plain)
                    .foregroundColor(Theme.primaryText)
                    .onChange(of: title) { _ in updateNote() }

                Spacer()

                Menu {
                    ForEach(NoteTint.allCases) { tint in
                        Button(action: { notesStore.updateTint(for: note, tint: tint) }) {
                            Label(tint.id.capitalized, systemImage: note.tint == tint ? "checkmark" : "")
                        }
                    }
                } label: {
                    Capsule()
                        .fill(note.tint.gradient)
                        .frame(width: 60, height: 24)
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.4), lineWidth: 0.8)
                        )
                        .shadow(color: note.tint.color.opacity(0.3), radius: 10, y: 4)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                }
                .padding(.horizontal, 32)
                .padding(.top, 28)
                .padding(.bottom, 16)

                Divider()
                    .background(Theme.separator)

                LatexTextViewRepresentable(text: $content, configuration: settingsStore.configuration) { newValue in
                    notesStore.update(note: note, title: title, content: newValue)
                }
                .background(Theme.editorBackground)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Theme.editorBackground.ignoresSafeArea())
        .onChange(of: notesStore.notes) { _ in
            if let note = currentNote {
                if title != note.title {
                    title = note.title
                }
                if content != note.content {
                    content = note.content
                }
            }
        }
    }

    private func updateNote() {
        guard let note = currentNote else { return }
        notesStore.update(note: note, title: title, content: content)
    }

    private var currentNote: Note? {
        notesStore.notes.first { $0.id == noteID }
    }
}
