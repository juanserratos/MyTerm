import AppKit
import WebKit

@MainActor
final class LatexRenderer: NSObject {
    static let shared = LatexRenderer()

    private let webView: WKWebView
    private var isLoaded = false

    override init() {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.limitsNavigationsToAppBoundDomains = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        webView = WKWebView(frame: .zero, configuration: config)
        webView.isHidden = true
        webView.setValue(false, forKey: "drawsBackground")
        webView.isOpaque = false
        webView.navigationDelegate = self
        super.init()
        loadRenderer()
    }

    private func loadRenderer() {
        guard !isLoaded else { return }
        if let url = Bundle.module.url(forResource: "renderer", withExtension: "html", subdirectory: "Renderer") {
            isLoaded = false
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    func render(_ latex: String, displayMode: Bool, configuration: LatexRenderConfiguration) async throws -> NSImage {
        try await waitUntilLoaded()
        let escapedLatex = latex
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "")
        let macrosJSON = try encodeMacros(configuration: configuration)
        let script = "renderKatex(\"\(escapedLatex)\", \(displayMode ? "true" : "false"), \(macrosJSON))"
        guard let sizeDict = try await webView.callAsyncJavaScript(script) as? [String: Any] else {
            throw LatexRendererError.failedToDecode
        }

        func extract(_ key: String) -> Double? {
            if let value = sizeDict[key] as? Double { return value }
            if let number = sizeDict[key] as? NSNumber { return number.doubleValue }
            return nil
        }

        guard let width = extract("width"), let height = extract("height") else {
            throw LatexRendererError.failedToDecode
        }

        let size = CGSize(width: max(width + 24, 1), height: max(height + 24, 1))
        await MainActor.run {
            webView.setFrameSize(size)
            webView.layoutSubtreeIfNeeded()
        }

        let configuration = WKSnapshotConfiguration()
        configuration.rect = CGRect(origin: .zero, size: size)
        configuration.afterScreenUpdates = true
        guard let image = try await webView.takeSnapshot(with: configuration) else {
            throw LatexRendererError.failedToDecode
        }
        return image
    }

    private func encodeMacros(configuration: LatexRenderConfiguration) throws -> String {
        var macros = configuration.macros
        for environment in configuration.environments {
            macros["\\begin{\(environment.name)}"] = environment.beginBody
            macros["\\end{\(environment.name)}"] = environment.endBody
        }

        guard let data = try? JSONSerialization.data(withJSONObject: macros, options: []) else {
            throw LatexRendererError.failedToEncodeMacros
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw LatexRendererError.failedToEncodeMacros
        }
        return string
    }

    private func waitUntilLoaded() async throws {
        var attempt = 0
        while !isLoaded {
            try await Task.sleep(nanoseconds: 50_000_000)
            attempt += 1
            if attempt > 20 {
                throw LatexRendererError.rendererNotLoaded
            }
        }
    }
}

enum LatexRendererError: Error {
    case rendererNotLoaded
    case failedToEncodeMacros
    case failedToDecode
}

extension LatexRenderer: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoaded = true
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        isLoaded = false
        loadRenderer()
    }
}
