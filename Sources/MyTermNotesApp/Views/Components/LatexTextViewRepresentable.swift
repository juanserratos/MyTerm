import SwiftUI
import AppKit

struct LatexTextViewRepresentable: NSViewRepresentable {
    @Binding var text: String
    var configuration: LatexRenderConfiguration
    var onUpdate: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, configuration: configuration, onUpdate: onUpdate)
    }

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isRichText = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textContainerInset = NSSize(width: 20, height: 20)
        textView.backgroundColor = NSColor.controlBackgroundColor
        textView.string = text
        textView.allowsUndo = true
        textView.usesAdaptiveColorMappingForDarkAppearance = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        context.coordinator.renderLatex(in: textView)
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        context.coordinator.configuration = configuration
        if nsView.string != text {
            nsView.string = text
            context.coordinator.renderLatex(in: nsView)
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        var configuration: LatexRenderConfiguration
        var onUpdate: (String) -> Void
        private var isApplyingAttributedString = false

        init(text: Binding<String>, configuration: LatexRenderConfiguration, onUpdate: @escaping (String) -> Void) {
            _text = text
            self.configuration = configuration
            self.onUpdate = onUpdate
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            guard !isApplyingAttributedString else { return }
            text = textView.string
            onUpdate(textView.string)
            renderLatex(in: textView)
        }

        func renderLatex(in textView: NSTextView) {
            let currentSelected = textView.selectedRange()
            let baseAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: NSColor.labelColor
            ]
            let attributed = NSMutableAttributedString(string: textView.string, attributes: baseAttributes)
            let segments = LatexParser.segments(in: textView.string)
            let renderConfiguration = configuration

            if segments.isEmpty {
                isApplyingAttributedString = true
                textView.textStorage?.setAttributedString(attributed)
                textView.setSelectedRange(currentSelected)
                isApplyingAttributedString = false
                return
            }

            Task { @MainActor [weak self] in
                guard let self else { return }
                for segment in segments.reversed() {
                    do {
                        let image = try await LatexRenderer.shared.render(segment.latex, displayMode: segment.displayMode, configuration: renderConfiguration)
                        let attachment = LatexAttachmentBuilder.makeAttachment(from: image)
                        let replacement = NSAttributedString(attachment: attachment)
                        attributed.replaceCharacters(in: segment.range, with: replacement)
                    } catch {
                        continue
                    }
                }

                self.isApplyingAttributedString = true
                textView.textStorage?.setAttributedString(attributed)
                textView.setSelectedRange(currentSelected)
                self.isApplyingAttributedString = false
            }
        }
    }
}
