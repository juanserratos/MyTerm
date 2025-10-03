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
                .frame(width: 280)
                .background(sidebarBackground)
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color.black.opacity(0.16), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                }

            Divider()
                .blendMode(.overlay)

            if let binding = store.binding(for: store.selectedNoteID) {
                NoteDetailView(note: binding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            } else {
                PlaceholderView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(mainBackground)
        .ignoresSafeArea()
    }

    private var sidebarBackground: some View {
        LinearGradient(
            colors: [
                Color(hex: 0x05060A).opacity(colorScheme == .dark ? 0.92 : 0.06),
                Color(hex: 0x0B0D12).opacity(colorScheme == .dark ? 0.88 : 0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(colorScheme == .dark ? Color.black : Color(nsColor: .windowBackgroundColor))
    }

    private var mainBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: 0x05060A), Color(hex: 0x0F1116)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(colorScheme == .dark ? 1.0 : 0.08)
        .background(colorScheme == .dark ? Color.black : Color(nsColor: .textBackgroundColor))
    }
}

private struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(.tertiary)
            Text("Select or create a note")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NotesStore())
        .frame(width: 1024, height: 768)
}
