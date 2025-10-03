import SwiftUI

@main
struct MyTermNotesApp: App {
    @StateObject private var notesStore = NotesStore()
    @StateObject private var settingsStore = LatexSettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notesStore)
                .environmentObject(settingsStore)
                .frame(minWidth: 960, minHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(action: notesStore.createNote) {
                    Text("New Note")
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
        }

        Settings {
            LatexSettingsView()
                .environmentObject(settingsStore)
                .padding(24)
                .frame(width: 520, height: 520)
        }
    }
}
