import Foundation
import PackagePlugin

struct Configuration {
    let args: [String: [String]]?
}

extension Configuration {
    private static let fileName = ".prefire.yml"

    static func from(rootPaths: [Path]) -> Configuration? {
        for path in rootPaths {
            if let configuration = Configuration.from(rootPath: path) {
                return configuration
            }
        }
        return nil
    }

    private static func from(rootPath: Path) -> Configuration? {
        let configUrl = URL(fileURLWithPath: rootPath.appending(subpath: Configuration.fileName).string)
        Diagnostics.remark("Trying to find a '.prefire.yml' from the path: \(configUrl.path)")

        guard FileManager.default.fileExists(atPath: configUrl.path),
              let configDataString = try? String(contentsOf: configUrl, encoding: .utf8) else { return nil }

        Diagnostics.remark("🟢 Successfully found and will use the file '.prefire.yml' on the path: \(configUrl.path)")

        return Configuration(
            args: getArgsFrom(configDataString: configDataString)
        )
    }

    private static func getArgsFrom(configDataString: String) -> [String: [String]]? {
        // Consider using a YAML parser?
        let testables = configDataString.matches(regex: "(args:|\\s+" + "testable" + ":)(.+)")
            .first?.components(separatedBy: ": ").last?
            .components(separatedBy: ", ")
        let imports = configDataString.matches(regex: "(args:|\\s+" + "import" + ":)(.+)")
            .first?.components(separatedBy: ": ").last?
            .components(separatedBy: ", ")
        return [
            "testable": testables ?? [],
            "import" : imports ?? []
        ]
    }
}

// MARK: - Extension regex

private extension String {
    func matches(regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive]) else { return [] }
        let matches  = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.map { match in
            String(self[Range(match.range, in: self)!])
        }
    }
}
