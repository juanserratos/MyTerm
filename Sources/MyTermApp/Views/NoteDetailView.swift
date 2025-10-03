import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @EnvironmentObject private var store: NotesStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var showingLatexSettings = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .overlay(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
            editor
        }
        .background(backgroundLayer)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .sheet(isPresented: $showingLatexSettings) {
            LatexSettingsView(
                macroText: $store.latexMacroDefinitions,
                environmentText: $store.latexEnvironmentDefinitions
            )
            .environmentObject(store)
            .frame(minWidth: 520, minHeight: 420)
        }
    }

    private var backgroundLayer: some View {
        let base = colorScheme == .dark ? Color.black.opacity(0.42) : Color.white.opacity(0.88)
        return base
            .overlay(
                LinearGradient(
                    colors: [Color.white.opacity(colorScheme == .dark ? 0.08 : 0.2), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .background(.ultraThinMaterial)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 16) {
                TextField("Title", text: $note.title)
                    .textFieldStyle(.plain)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .onChange(of: note.title) { _ in
                        note.updatedAt = .now
                    }

                Spacer()

                Button {
                    showingLatexSettings = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "function")
                        Text("LaTeX Palette")
                            .font(.footnote.weight(.semibold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.16))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open LaTeX palette")
            }

            Text(note.updatedAt, format: .dateTime.month().day().year().hour().minute())
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 24)
    }

    private var editor: some View {
        NoteEditorContainer(note: $note, latexPreamble: store.latexPreamble)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
    }
}
