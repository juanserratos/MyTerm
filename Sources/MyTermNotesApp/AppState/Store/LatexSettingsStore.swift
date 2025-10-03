import Combine
import Foundation

@MainActor
final class LatexSettingsStore: ObservableObject {
    @Published var commandSet: LatexCommandSet

    private let storageURL: URL

    init(fileManager: FileManager = .default) {
        let support = try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        storageURL = support?.appending(path: "MyTermNotes/latex.json") ?? URL(fileURLWithPath: NSTemporaryDirectory()).appending(path: "MyTermNotes/latex.json")
        if let data = try? Data(contentsOf: storageURL),
           let decoded = try? JSONDecoder().decode(LatexCommandSet.self, from: data) {
            commandSet = decoded
        } else {
            commandSet = .default
        }

        $commandSet
            .dropFirst()
            .debounce(for: .seconds(0.6), scheduler: RunLoop.main)
            .sink { [weak self] commandSet in
                Task { await self?.persist(commandSet) }
            }
            .store(in: &cancellables)
    }

    var configuration: LatexRenderConfiguration {
        LatexRenderConfiguration(macros: commandSet.macros, environments: commandSet.environments)
    }

    private var cancellables: Set<AnyCancellable> = []

    private func persist(_ commandSet: LatexCommandSet) async {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(commandSet)
            try FileManager.default.createDirectory(at: storageURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            NSLog("Failed to persist LaTeX command set: \(error.localizedDescription)")
        }
    }
}
