import SwiftUI

@main
struct MyTermApp: App {
    @StateObject private var store = NotesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 960, minHeight: 640)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1080, height: 720)

        Settings {
            LatexSettingsView(
                macroText: $store.latexMacroDefinitions,
                environmentText: $store.latexEnvironmentDefinitions
            )
            .frame(minWidth: 520, idealWidth: 560, minHeight: 420, idealHeight: 460)
            .environmentObject(store)
        }
    }
}
