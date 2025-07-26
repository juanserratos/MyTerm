# MyTerm

MyTerm is a simple SwiftUI terminal application for macOS that can preview Markdown
and LaTeX alongside a fully functional terminal emulator. It uses
[SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) for the terminal,
[MarkdownUI](https://github.com/gonzalezreal/MarkdownUI) for Markdown rendering
and [iosMath](https://github.com/kostub/iosMath) for LaTeX rendering.

## Building

The project relies on Swift Package Manager. The `iosMath` package does not have
an official release that includes its `Package.swift` manifest. Therefore the
`Package.swift` file in this repository points to the `master` branch of
`iosMath`.

Clone the repository and open the Xcode project (`MyTerm.xcodeproj`) on macOS
14 or later. Running the project will launch a window containing the terminal,
a text editor and a preview pane that can toggle between Markdown and LaTeX
rendering.

