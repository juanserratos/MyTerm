import SwiftUI

struct ContentView: View {
    @State private var input: String = ""
    @State private var showMarkdown: Bool = true

    var body: some View {
        HStack {
            TerminalWrapper()
                .frame(minWidth: 400, minHeight: 300)
            Divider()
            VStack {
                TextEditor(text: $input)
                    .border(Color.secondary)
                    .frame(minHeight: 150)
                Picker("Mode", selection: $showMarkdown) {
                    Text("Markdown").tag(true)
                    Text("LaTeX").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical)
                if showMarkdown {
                    MarkdownPreview(text: input)
                } else {
                    LaTeXPreview(text: input)
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
