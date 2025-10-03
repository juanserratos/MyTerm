import Foundation

struct LatexSegment: Identifiable, Hashable {
    let id = UUID()
    let range: NSRange
    let latex: String
    let displayMode: Bool
}

enum LatexParser {
    static func segments(in text: String) -> [LatexSegment] {
        var segments: [LatexSegment] = []
        let nsText = text as NSString

        // Block $$...$$ and \[ ... \]
        let blockPatterns = [
            #"\$\$(.+?)\$\$"#,
            #"\\\[(.+?)\\\]"#
        ]
        for pattern in blockPatterns {
            if let blockRegex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
            let matches = blockRegex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
            for match in matches {
                guard match.numberOfRanges >= 2 else { continue }
                let latexRange = match.range(at: 1)
                let displayRange = match.range(at: 0)
                let latex = nsText.substring(with: latexRange)
                segments.append(LatexSegment(range: displayRange, latex: latex, displayMode: true))
            }
        }
        }

        // Environments \begin{...} ... \end{...}
        if let envRegex = try? NSRegularExpression(pattern: #"\\begin\{([a-zA-Z*]+)\}([\\s\\S]*?)\\end\{\1\}"#, options: []) {
            let matches = envRegex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
            for match in matches {
                guard match.numberOfRanges >= 3 else { continue }
                let contentRange = match.range(at: 0)
                let latex = nsText.substring(with: contentRange)
                segments.append(LatexSegment(range: contentRange, latex: latex, displayMode: true))
            }
        }

        // Inline $...$ and \(...\)
        let inlinePatterns = [
            #"(?<!\\)\$(.+?)(?<!\\)\$"#,
            #"\\\((.+?)\\\)"#
        ]
        for pattern in inlinePatterns {
            if let inlineRegex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = inlineRegex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
                for match in matches {
                    guard match.numberOfRanges >= 2 else { continue }
                    let latexRange = match.range(at: 1)
                    let displayRange = match.range(at: 0)
                    let latex = nsText.substring(with: latexRange)
                    segments.append(LatexSegment(range: displayRange, latex: latex, displayMode: latex.contains("\\n")))
                }
            }
        }

        // Deduplicate overlapping ranges, prioritizing larger blocks
        let sorted = segments.sorted { lhs, rhs in
            if lhs.range.location == rhs.range.location {
                return lhs.range.length > rhs.range.length
            }
            return lhs.range.location < rhs.range.location
        }

        var deduped: [LatexSegment] = []
        for segment in sorted {
            if deduped.contains(where: { NSIntersectionRange($0.range, segment.range).length > 0 }) {
                continue
            }
            deduped.append(segment)
        }

        return deduped.sorted { $0.range.location < $1.range.location }
    }
}
