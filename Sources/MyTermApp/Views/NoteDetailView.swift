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
        VStack(alignment: .leading, spacing: 4) {
            TextField("Title", text: $note.title)
                .textFieldStyle(.plain)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
                .onChange(of: note.title) { _ in
                    note.updatedAt = .now
                }

            Text(note.updatedAt, format: .dateTime.month().day().year().hour().minute())
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 28)
        .padding(.top, 22)
        .padding(.bottom, 14)
    }

    private var editor: some View {
        NoteEditorContainer(note: $note)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
    }
}
