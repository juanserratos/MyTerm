import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .foregroundStyle(.quaternary)
            editor
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Title", text: $note.title)
                .textFieldStyle(.plain)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)
                .onChange(of: note.title) { _ in
                    note.updatedAt = .now
                }

            Text(note.updatedAt, format: .dateTime.month().day().year().hour().minute())
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 32)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    private var editor: some View {
        NoteEditorContainer(note: $note)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
    }
}
