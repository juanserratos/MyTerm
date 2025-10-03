import SwiftUI

enum Theme {
    static let accent = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let sidebarBackground = Color(nsColor: NSColor.windowBackgroundColor).opacity(0.92)
    static let editorBackground = Color(nsColor: NSColor.controlBackgroundColor)
    static let primaryText = Color.primary
    static let separator = Color.black.opacity(0.05)

    static let accentGradient = LinearGradient(
        colors: [accent.opacity(0.92), accent.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
