import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var notesStore: NotesStore
    @EnvironmentObject private var settingsStore: LatexSettingsStore

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedNote: Binding(
                get: { selectedNote },
                set: { notesStore.select($0) }
            ))
            .navigationSplitViewColumnWidth(min: 240, ideal: 260)
            .background(Theme.sidebarBackground)
        } detail: {
            if let selectedNote {
                NoteEditorContainer(note: selectedNote)
                    .environmentObject(settingsStore)
                    .environmentObject(notesStore)
                    .background(Theme.editorBackground)
            } else {
                PlaceholderView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.editorBackground)
            }
        }
        .tint(Theme.accent)
    }

    private var selectedNote: Note? {
        guard let id = notesStore.selectedNoteID else { return nil }
        return notesStore.notes.first { $0.id == id }
    }
}

struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 52, weight: .medium))
                .foregroundStyle(.ultraThinMaterial)
            Text("Choose or create a note")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}
