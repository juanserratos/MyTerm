import SwiftUI
import iosMath

#if os(macOS)
struct LaTeXPreview: NSViewRepresentable {
    var text: String

    func makeNSView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.latex = text
        label.fontSize = 18
        label.textAlignment = .left
        return label
    }

    func updateNSView(_ nsView: MTMathUILabel, context: Context) {
        nsView.latex = text
    }
}
#else
struct LaTeXPreview: UIViewRepresentable {
    var text: String

    func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.latex = text
        label.fontSize = 18
        label.textAlignment = .left
        return label
    }

    func updateUIView(_ uiView: MTMathUILabel, context: Context) {
        uiView.latex = text
    }
}
#endif
