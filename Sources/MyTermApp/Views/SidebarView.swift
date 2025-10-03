import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: NotesStore
    @State private var hoveredNoteID: UUID?

    let notes: [Note]

    var body: some View {
        VStack(spacing: 0) {
            header
            searchField
            Divider()
                .foregroundStyle(.quaternary)
            notesList
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(.system(size: 22, weight: .semibold))
                Text("All iCloud")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: store.createNote) {
                Image(systemName: "square.and.pencil")
                    .symbolVariant(.fill)
                    .font(.system(size: 15, weight: .medium))
                    .padding(6)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .accessibilityLabel("Create a new note")
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search", text: $store.searchText)
                .textFieldStyle(.plain)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(nsColor: .quaternaryLabelColor))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var notesList: some View {
        List(selection: $store.selectedNoteID) {
            ForEach(notes) { note in
                NoteRow(note: note, isHovered: hoveredNoteID == note.id)
                    .listRowBackground(Color.clear)
                    .tag(note.id)
                    .onHover { hovering in
                        hoveredNoteID = hovering ? note.id : nil
                    }
            }
            .onDelete(perform: deleteNotes)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
    }

    private func deleteNotes(at offsets: IndexSet) {
        let ids = offsets.compactMap { index -> UUID? in
            guard notes.indices.contains(index) else { return nil }
            return notes[index].id
        }
        store.deleteNotes(withIDs: ids)
    }
}

private struct NoteRow: View {
    let note: Note
    let isHovered: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            Text(note.previewLine)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
}
