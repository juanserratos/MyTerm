# MyTerm Notes

A SwiftUI-based macOS note-taking experience inspired by Apple Notes with a Vercel aesthetic and native-quality LaTeX rendering. Mathematical expressions typed with `$ ... $`, `$$ ... $$`, `\( ... \)`, `\[ ... \]`, or LaTeX environments render inline while keeping the editing experience smooth.

## Highlights

- **Elegant interface** that echoes macOS Notes while leaning into Vercel-inspired neutrals, translucency, and rounded geometry.
- **Realtime LaTeX** rendering powered by an off-screen WebKit renderer and KaTeX. Inline and display math, matrices, alignment environments, and theorem-style blocks render directly in the editor.
- **Custom macro support** for `\newcommand`, `\DeclareMathOperator`, and `\newenvironment` definitions via the app's Settings pane.
- **Persistent storage** using Application Support so notes and LaTeX preferences are restored between launches.
- **Keyboard-friendly workflow** with Command+N to create notes and familiar macOS split-view navigation.

## Getting Started

1. Open the project in Xcode 15 or newer (macOS 13 target).
2. Build & run the executable target `MyTermNotes` on macOS.
3. Use the Settings pane (`⌘,`) to paste your favorite LaTeX macros and environment definitions.

## Project Structure

- `Package.swift` — Swift Package Manager manifest configured for a SwiftUI App target.
- `Sources/MyTermNotesApp` — Application sources (app state, views, LaTeX renderer, theme).
- `Resources/Renderer` — HTML harness used by the off-screen WebKit renderer to produce KaTeX snapshots.

## Requirements

- macOS 13+
- Xcode 15+

KaTeX assets are served from jsDelivr CDN. An active internet connection is required for the first render to download KaTeX once per session.
