import SwiftUI
import AppKit

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField(string: text)
        searchField.placeholderString = placeholder
        searchField.sendsSearchStringImmediately = true
        searchField.sendsWholeSearchString = true
        searchField.target = context.coordinator
        searchField.action = #selector(Coordinator.performSearch(_:))
        searchField.delegate = context.coordinator
        searchField.focusRingType = .none
        searchField.font = .systemFont(ofSize: NSFont.systemFontSize)
        return searchField
    }

    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        nsView.placeholderString = placeholder
    }

    final class Coordinator: NSObject, NSSearchFieldDelegate {
        private var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        @objc
        func performSearch(_ sender: NSSearchField) {
            text.wrappedValue = sender.stringValue
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let field = notification.object as? NSSearchField else { return }
            text.wrappedValue = field.stringValue
        }
    }
}
