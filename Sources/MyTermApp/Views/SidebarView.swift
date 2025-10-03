import SwiftUI
import AppKit

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
        .background(Color(nsColor: .underPageBackgroundColor))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(.system(size: 19, weight: .semibold))
                Text("All iCloud")
                    .font(.system(size: 12, weight: .medium))
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
        SearchField(text: $store.searchText, placeholder: "Search")
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
    }

    private var notesList: some View {
        List(selection: $store.selectedNoteID) {
            ForEach(notes) { note in
                NoteRow(
                    note: note,
                    isHovered: hoveredNoteID == note.id,
                    isSelected: store.selectedNoteID == note.id
                )
                    .listRowBackground(Color.clear)
                    .tag(note.id)
                    .onHover { hovering in
                        hoveredNoteID = hovering ? note.id : nil
                    }
            }
            .onDelete(perform: deleteNotes)
        }
        .listStyle(.inset)
        .environment(\.defaultMinListRowHeight, 54)
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
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(note.title.isEmpty ? "New Note" : note.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(primaryTextStyle)
                    .lineLimit(1)
                Spacer(minLength: 6)
                Text(note.updatedAt, format: .dateTime.month().day())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(secondaryTextStyle)
            }
            Text(note.previewLine)
                .font(.system(size: 13))
                .foregroundStyle(secondaryTextStyle)
                .lineLimit(2)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 8)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(Rectangle())
    }

    private var rowBackground: some View {
        Group {
            if isSelected {
                Color(nsColor: NSColor.selectedContentBackgroundColor)
            } else if isHovered {
                Color(nsColor: NSColor.windowBackgroundColor.withAlphaComponent(0.6))
            } else {
                Color.clear
            }
        }
    }

    private var primaryTextStyle: Color {
        if isSelected {
            Color(nsColor: NSColor.alternateSelectedControlTextColor)
        } else {
            .primary
        }
    }

    private var secondaryTextStyle: Color {
        if isSelected {
            Color(nsColor: NSColor.alternateSelectedControlTextColor).opacity(0.85)
        } else {
            .secondary
        }
    }
}
