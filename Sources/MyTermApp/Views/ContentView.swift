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
        ZStack {
            mainBackground
                .ignoresSafeArea()

            HStack(spacing: 0) {
                SidebarView(notes: filteredNotes)
                    .frame(width: 288)
                    .background(sidebarBackground)
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [Color.white.opacity(colorScheme == .dark ? 0.08 : 0.18), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 96)
                    }

                Divider()
                    .blendMode(.overlay)

                if let binding = store.binding(for: store.selectedNoteID) {
                    NoteDetailView(note: binding)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                        .padding(.trailing, 28)
                } else {
                    PlaceholderView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.trailing, 28)
                }
            }
            .padding(.bottom, 18)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            TitleBarChrome()
        }
    }

    private var sidebarBackground: some View {
        LinearGradient(
            colors: [
                Color(hex: 0x05060A).opacity(colorScheme == .dark ? 0.92 : 0.08),
                Color(hex: 0x080B12).opacity(colorScheme == .dark ? 0.88 : 0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(colorScheme == .dark ? Color.black : Color(nsColor: .windowBackgroundColor))
        .overlay(
            LinearGradient(
                colors: [Color.white.opacity(colorScheme == .dark ? 0.04 : 0.12), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var mainBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: 0x05060A), Color(hex: 0x0F1116), Color(hex: 0x05060A)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            AngularGradient(
                gradient: Gradient(colors: [
                    Color(hex: 0x19FB9B).opacity(0.35),
                    Color(hex: 0x0EA5E9).opacity(0.4),
                    Color(hex: 0x6366F1).opacity(0.32),
                    Color(hex: 0x19FB9B).opacity(0.35)
                ]),
                center: .topLeading,
                angle: .degrees(135)
            )
            .opacity(colorScheme == .dark ? 0.22 : 0.08)
            .blur(radius: 160)
        )
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

private struct TitleBarChrome: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .background(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.08 : 0.3),
                            Color.black.opacity(colorScheme == .dark ? 0.5 : 0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 12) {
                WindowControls()
                Spacer()
                Text("MyTerm Notes")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(colorScheme == .dark ? 0.7 : 0.55))
                Spacer()
                Capsule()
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.16))
                    .frame(width: 92, height: 26)
                    .overlay(
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11, weight: .semibold))
                            Text("KaTeX")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(Color.white.opacity(colorScheme == .dark ? 0.88 : 0.7))
                    )
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 10)
        }
        .frame(height: 52)
        .overlay(
            Divider()
                .overlay(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.14)),
            alignment: .bottom
        )
    }
}

private struct WindowControls: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(red: 1.0, green: 0.39, blue: 0.35))
            Circle()
                .fill(Color(red: 1.0, green: 0.78, blue: 0.32))
            Circle()
                .fill(Color(red: 0.32, green: 0.83, blue: 0.39))
        }
        .frame(height: 12)
        .padding(.leading, 4)
        .overlay(
            HStack(spacing: 8) {
                Circle().stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                Circle().stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                Circle().stroke(Color.white.opacity(0.12), lineWidth: 0.5)
            }
            .frame(height: 12)
        )
        .frame(width: 60, alignment: .leading)
    }
}

#Preview {
    ContentView()
        .environmentObject(NotesStore())
        .frame(width: 1024, height: 768)
}
