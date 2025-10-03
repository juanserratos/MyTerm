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
                .overlay(Color.white.opacity(0.05))
            notesList
        }
        .padding(.top, 12)
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                Text("All iCloud")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: store.createNote) {
                Label("New", systemImage: "square.and.pencil")
                    .labelStyle(.iconOnly)
                    .font(.title3.weight(.semibold))
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Create a new note")
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private var searchField: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search", text: $store.searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(.primary)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
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
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
            Text(note.previewLine)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill((isHovered ? Color.white.opacity(0.08) : Color.white.opacity(0.04)))
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
