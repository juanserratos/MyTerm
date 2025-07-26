import SwiftUI
import MarkdownUI

struct MarkdownPreview: View {
    var text: String
    var body: some View {
        ScrollView {
            Markdown(text)
                .padding()
        }
    }
}
