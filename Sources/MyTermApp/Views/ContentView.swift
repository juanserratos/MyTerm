import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: NotesStore
    @Environment(\.colorScheme) private var colorScheme

    private var filteredNotes: [Note] {
        guard !store.searchText.isEmpty else { return store.notes }
        let query = store.searchText.lowercased()
        return store.notes.filter { note in
            note.title.lowercased().contains(query) || note.content.lowercased().contains(query)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(notes: filteredNotes)
                .frame(width: 260)
                .background(sidebarBackground)

            Divider()
                .foregroundStyle(.quaternary)

            if let binding = store.binding(for: store.selectedNoteID) {
                NoteDetailView(note: binding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(mainBackground)
            } else {
                PlaceholderView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(mainBackground)
            }
        }
        .frame(minWidth: 960, minHeight: 600)
        .background(windowBackground)
    }

    private var sidebarBackground: some View {
        Color(nsColor: colorScheme == .dark ? .controlBackgroundColor : .windowBackgroundColor)
    }

    private var mainBackground: some View {
        Color(nsColor: colorScheme == .dark ? .textBackgroundColor : .underPageBackgroundColor)
    }

    private var windowBackground: some View {
        Color(nsColor: .windowBackgroundColor)
            .ignoresSafeArea()
    }
}

private struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 34, weight: .ultraLight))
                .foregroundStyle(.quaternary)
            Text("Select a note to view or create a new one")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NotesStore())
        .frame(width: 1024, height: 768)
}
