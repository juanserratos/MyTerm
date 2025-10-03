import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var notesStore: NotesStore
    @State private var searchText = ""
    @Binding var selectedNote: Note?

    private var filteredNotes: [Note] {
        guard !searchText.isEmpty else { return notesStore.notes }
        return notesStore.notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Text("Notes")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Spacer()
                    Button(action: notesStore.createNote) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Theme.accentGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                            .shadow(color: Theme.accent.opacity(0.4), radius: 12, y: 6)
                    }
                    .buttonStyle(.plain)
                    .help("Create a new note")
                }

                TextField("Search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .cornerRadius(12)
                    .padding(.top, 4)
            }
            .padding(20)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(filteredNotes) { note in
                        NoteListItemView(note: note, isSelected: selectedNote?.id == note.id)
                            .contentShape(Rectangle())
                            .onTapGesture { selectedNote = note }
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    notesStore.delete(note)
                                }
                                Divider()
                                Menu("Tint") {
                                    ForEach(NoteTint.allCases) { tint in
                                        Button(action: { applyTint(tint, to: note) }) {
                                            Label(tint.id.capitalized, systemImage: note.tint == tint ? "checkmark" : "")
                                        }
                                    }
                                }
                            }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .background(Theme.sidebarBackground)
    }

    private func applyTint(_ tint: NoteTint, to note: Note) {
        notesStore.updateTint(for: note, tint: tint)
    }
}
