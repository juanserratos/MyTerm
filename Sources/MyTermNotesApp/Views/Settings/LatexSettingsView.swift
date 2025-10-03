import SwiftUI

struct LatexSettingsView: View {
    @EnvironmentObject private var settingsStore: LatexSettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("LaTeX Commands")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("Paste your custom \newcommand, \DeclareMathOperator, and \newenvironment definitions. These macros will be available across every note.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }

            TextEditor(text: Binding(
                get: { settingsStore.commandSet.macrosSource },
                set: { newValue in settingsStore.commandSet.macrosSource = newValue }
            ))
            .font(.system(size: 14, weight: .regular, design: .monospaced))
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(nsColor: NSColor.controlBackgroundColor))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )

            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text("Tips")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Label("Inline math: $f(x) = x^2$", systemImage: "function")
                Label("Display math: $$\\begin{align*} a & = b \\ c & = d \end{align*}$$", systemImage: "text.alignleft")
                Label("Environment blocks: \\begin{lemma} ... \\end{lemma}", systemImage: "square.grid.2x2")
                Label("Operators: \\DeclareMathOperator{\\Spec}{Spec}", systemImage: "sum")
            }
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(.secondary)
        }
        .padding(24)
    }
}
