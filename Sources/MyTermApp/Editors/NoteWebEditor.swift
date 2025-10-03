import SwiftUI
import WebKit

struct NoteWebEditor: NSViewRepresentable {
    @Binding var note: Note
    var colorScheme: ColorScheme
    var latexPreamble: String

    func makeCoordinator() -> Coordinator {
        Coordinator(note: $note)
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        configuration.userContentController.add(context.coordinator, name: Coordinator.messageName)

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.setValue(false, forKey: "drawsBackground")
        webView.allowsMagnification = false

        if let url = Bundle.module.url(forResource: "editor", withExtension: "html", subdirectory: "Editor") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        context.coordinator.webView = webView
        context.coordinator.pendingContent = note.content
        context.coordinator.pendingTitle = note.title
        context.coordinator.pendingTheme = colorScheme
        context.coordinator.pendingPreamble = latexPreamble

        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        context.coordinator.updateNote(note)
        context.coordinator.updateThemeIfNeeded(colorScheme)
        context.coordinator.updatePreambleIfNeeded(latexPreamble)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        static let messageName = "noteChanged"

        weak var webView: WKWebView?
        private var isLoaded = false
        private var lastSyncedContent: String = ""
        private var lastSyncedTitle: String = ""
        private var lastTheme: ColorScheme = .light
        private var lastPreamble: String = ""

        var pendingContent: String = ""
        var pendingTitle: String = ""
        var pendingTheme: ColorScheme = .light
        var pendingPreamble: String = ""

        private var noteBinding: Binding<Note>

        init(note: Binding<Note>) {
            self.noteBinding = note
        }

        func updateNote(_ note: Note) {
            guard isLoaded else {
                pendingContent = note.content
                pendingTitle = note.title
                return
            }

            if note.content != lastSyncedContent {
                setContent(note.content)
            }

            if note.title != lastSyncedTitle {
                setTitle(note.title)
            }
        }

        func updateThemeIfNeeded(_ theme: ColorScheme) {
            guard isLoaded else {
                pendingTheme = theme
                return
            }

            if theme != lastTheme {
                applyTheme(theme)
            }
        }

        func updatePreambleIfNeeded(_ preamble: String) {
            guard isLoaded else {
                pendingPreamble = preamble
                return
            }

            if preamble != lastPreamble {
                setPreamble(preamble)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
            setPreamble(pendingPreamble)
            setContent(pendingContent)
            setTitle(pendingTitle)
            applyTheme(pendingTheme)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == Coordinator.messageName else { return }
            if let body = message.body as? [String: Any] {
                handleMessage(body)
            } else if let text = message.body as? String {
                handleTextMessage(text)
            }
        }

        private func handleMessage(_ payload: [String: Any]) {
            if let content = payload["content"] as? String {
                handleTextMessage(content)
            }
            if let title = payload["title"] as? String {
                Task { @MainActor in
                    var current = noteBinding.wrappedValue
                    current.title = title
                    noteBinding.wrappedValue = current
                    lastSyncedTitle = title
                }
            }
        }

        private func handleTextMessage(_ text: String) {
            Task { @MainActor in
                var current = noteBinding.wrappedValue
                current.content = text
                current.updatedAt = .now
                current.title = Note.title(from: text, fallback: current.title)
                noteBinding.wrappedValue = current
                lastSyncedContent = text
                lastSyncedTitle = current.title
            }
        }

        private func setContent(_ text: String) {
            lastSyncedContent = text
            let escaped = text.escapedForJavaScript()
            let script = "window.noteBridge.setContent(\"\(escaped)\");"
            webView?.evaluateJavaScript(script) { _, error in
                #if DEBUG
                if let error {
                    print("JavaScript content error: \(error.localizedDescription)")
                }
                #endif
            }
        }

        private func setTitle(_ title: String) {
            lastSyncedTitle = title
            let escaped = title.escapedForJavaScript()
            let script = "window.noteBridge.setTitle(\"\(escaped)\");"
            webView?.evaluateJavaScript(script, completionHandler: nil)
        }

        private func setPreamble(_ preamble: String) {
            lastPreamble = preamble
            let escaped = preamble.escapedForJavaScript()
            let script = "window.noteBridge.setPreamble(\"\(escaped)\");"
            webView?.evaluateJavaScript(script, completionHandler: nil)
        }

        private func applyTheme(_ theme: ColorScheme) {
            lastTheme = theme
            let mode = theme == .dark ? "dark" : "light"
            let script = "window.noteBridge.setAppearance(\"\(mode)\");"
            webView?.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

private extension String {
    func escapedForJavaScript() -> String {
        var result = self
        result = result
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
        return result
    }
}
