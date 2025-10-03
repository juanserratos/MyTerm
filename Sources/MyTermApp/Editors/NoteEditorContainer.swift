import SwiftUI

struct NoteEditorContainer: View {
    @Binding var note: Note
    var latexPreamble: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NoteWebEditor(note: $note, colorScheme: colorScheme, latexPreamble: latexPreamble)
            .overlay(alignment: .bottomTrailing) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Live LaTeX")
                        .font(.caption.weight(.medium))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.thinMaterial, in: Capsule())
                .padding(12)
                .opacity(0.85)
            }
    }
}
