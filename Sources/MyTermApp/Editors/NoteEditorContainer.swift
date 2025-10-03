import SwiftUI

struct NoteEditorContainer: View {
    @Binding var note: Note
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NoteWebEditor(note: $note, colorScheme: colorScheme)
            .overlay(alignment: .bottomTrailing) {
                HStack(spacing: 8) {
                    Image(systemName: "function")
                    Text("LaTeX enabled")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.thinMaterial, in: Capsule())
                .padding(12)
                .opacity(0.85)
            }
    }
}
