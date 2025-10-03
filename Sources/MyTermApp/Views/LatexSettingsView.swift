import SwiftUI

struct LatexSettingsView: View {
    @Binding var macroText: String
    @Binding var environmentText: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Global commands & operators", subtitle: "Paste any \\newcommand or \\DeclareMathOperator definitions. They apply instantly across every note.")
                TextEditor(text: $macroText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 140)
                    .padding(12)
                    .background(editorBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Custom environments", subtitle: "Define theorem-style blocks with \\newenvironment. Titles like lemma or theorem will render in a framed badge.")
                TextEditor(text: $environmentText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 140)
                    .padding(12)
                    .background(editorBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Spacer()

            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
                Text("Inline math $a^2 + b^2$ and blocks like $\\begin{align*}\\end{align*}$ update live as you type.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(28)
        .frame(minWidth: 520, minHeight: 420)
        .background(settingsBackground)
    }

    private var editorBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.16))
    }

    private var settingsBackground: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [Color(hex: 0x08090C), Color(hex: 0x121621)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [Color.white, Color(hex: 0xF5F7FA)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .background(colorScheme == .dark ? Color.black : Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("LaTeX Palette")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                Text("Configure reusable macros and math environments for every note.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    LatexSettingsView(
        macroText: .constant("\\newcommand{\\RR}{\\mathbb{R}}"),
        environmentText: .constant("\\newenvironment{lemma}{\\begin{aligned}}{\\end{aligned}}")
    )
}
