import SwiftUI
import SwiftTerm

#if os(macOS)
struct TerminalWrapper: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let terminal = LocalProcessTerminalView(frame: .zero)
        terminal.startProcess()
        return terminal
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }
}
#else
struct TerminalWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let terminal = LocalProcessTerminalView(frame: .zero)
        terminal.startProcess()
        return terminal
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
#endif
