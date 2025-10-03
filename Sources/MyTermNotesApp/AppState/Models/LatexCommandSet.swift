import Foundation

struct LatexCommandSet: Codable, Equatable {
    var macrosSource: String

    var macros: [String: String] {
        var dictionary: [String: String] = [:]
        let lines = macrosSource.split(separator: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            if let command = LatexCommandSet.parseMacro(from: trimmed) {
                dictionary[command.key] = command.value
            }
        }
        return dictionary
    }

    var environments: [LatexEnvironment] {
        var definitions: [LatexEnvironment] = []
        let lines = macrosSource.split(separator: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            if let env = LatexCommandSet.parseEnvironment(from: trimmed) {
                definitions.append(env)
            }
        }
        return definitions
    }

    static func parseMacro(from line: String) -> (key: String, value: String)? {
        let patterns = [
            #"\\newcommand\{\\([a-zA-Z@]+)\}\{(.+)\}"#,
            #"\\DeclareMathOperator\{\\([a-zA-Z@]+)\}\{(.+)\}"#
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(line.startIndex..<line.endIndex, in: line)
                if let match = regex.firstMatch(in: line, options: [], range: range), match.numberOfRanges >= 3,
                   let keyRange = Range(match.range(at: 1), in: line),
                   let valueRange = Range(match.range(at: 2), in: line) {
                    let key = String(line[keyRange])
                    let value = String(line[valueRange])
                    return ("\\" + key, value)
                }
            }
        }
        return nil
    }

    static func parseEnvironment(from line: String) -> LatexEnvironment? {
        let pattern = #"\\newenvironment\{([a-zA-Z*@]+)\}\{(.+)\}\{(.+)\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)),
              match.numberOfRanges == 4,
              let nameRange = Range(match.range(at: 1), in: line),
              let beginRange = Range(match.range(at: 2), in: line),
              let endRange = Range(match.range(at: 3), in: line) else {
            return nil
        }

        return LatexEnvironment(
            name: String(line[nameRange]),
            beginBody: String(line[beginRange]),
            endBody: String(line[endRange])
        )
    }

    static let `default` = LatexCommandSet(
        macrosSource: """
\\newcommand{\\R}{\\mathbb{R}}
\\newcommand{\\Q}{\\mathbb{Q}}
\\newcommand{\\Z}{\\mathbb{Z}}
\\newcommand{\\N}{\\mathbb{N}}
\\DeclareMathOperator{\\im}{im}
\\DeclareMathOperator{\\Hom}{Hom}
\\newenvironment{lemma}{\\begin{aligned}}{\\end{aligned}}
"""
    )
}

struct LatexEnvironment: Codable, Equatable {
    var name: String
    var beginBody: String
    var endBody: String
}

struct LatexRenderConfiguration: Equatable {
    var macros: [String: String]
    var environments: [LatexEnvironment]
}
