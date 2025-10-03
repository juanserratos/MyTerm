import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @Environment(\.colorScheme) private var colorScheme

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
    }

    private var backgroundLayer: some View {
        let base = colorScheme == .dark ? Color.black.opacity(0.45) : Color.white.opacity(0.85)
        return base
            .overlay(
                LinearGradient(
                    colors: [Color.white.opacity(colorScheme == .dark ? 0.06 : 0.18), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .background(.ultraThinMaterial)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Title", text: $note.title)
                .textFieldStyle(.plain)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .onChange(of: note.title) { _ in
                    note.updatedAt = .now
                }

            Text(note.updatedAt, format: .dateTime.month().day().year().hour().minute())
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 24)
    }

    private var editor: some View {
        NoteEditorContainer(note: $note)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
    }
}
