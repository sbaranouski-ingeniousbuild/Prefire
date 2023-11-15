import Foundation
import PackagePlugin

@main
struct PrefirePlaybookPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let executable = try context.tool(named: "PrefireSourcery").path

        let configuration = Configuration.from(rootPaths: [target.directory, target.directory.removingLastComponent()])

        try FileManager.default.createDirectory(atPath: context.pluginWorkDirectory.string, withIntermediateDirectories: true)

        return [
            Command.prefireCommand(
                executablePath: executable,
                sources: target.directory,
                imports: target.recursiveTargetDependencies.map(\.name),
                generatedSourcesDirectory: context.pluginWorkDirectory,
                configuration: configuration)
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension PrefirePlaybookPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
        let executable = try context.tool(named: "PrefireSourcery").path

        let configuration = Configuration.from(rootPaths: [context.xcodeProject.directory.appending(subpath: target.displayName), context.xcodeProject.directory])

        try FileManager.default.createDirectory(atPath: context.pluginWorkDirectory.string, withIntermediateDirectories: true)

        return [
            Command.prefireCommand(
                executablePath: executable,
                sources: context.xcodeProject.directory,
                imports: [],
                generatedSourcesDirectory: context.pluginWorkDirectory,
                configuration: configuration)
        ]
    }
}
#endif

// MARK: - Extensions

extension Command {
    static func prefireCommand(
        executablePath executable: Path,
        sources: Path,
        imports: [String],
        generatedSourcesDirectory: Path,
        configuration: Configuration?
    ) -> Command {
        Diagnostics.remark(
        """
        Prefire configuration
        Preview sources path: \(sources.string)
        Generated preview models path: \(generatedSourcesDirectory)/PreviewModels.generated.swift
        """
        )

        let templatesDirectory = executable.string.components(separatedBy: "Binaries").first! + "Templates"

        var arguments: [CustomStringConvertible] = [
            "--templates",
            "\(templatesDirectory)/PreviewModels.stencil",
            "--sources",
            sources.string,
            "--args",
            "autoMockableImports=\(imports)",
            "--output",
            "\(generatedSourcesDirectory)/PreviewModels.generated.swift",
            "--cacheBasePath",
            generatedSourcesDirectory.string,
        ]

        configuration?.args?
            .forEach { key, values in
                // let valuesString = values.joined(separator: ",")
                arguments.append(contentsOf: ["--args", "\(key)=\(values)"])
            }

        if configuration?.args?.isEmpty == false {
            arguments.append(contentsOf: [
                "--args", "file=\(generatedSourcesDirectory)/PreviewModels.generated.swift"
            ])
        }

        return Command.prebuildCommand(
            displayName: "Running Prefire",
            executable: executable,
            arguments: arguments,
            outputFilesDirectory: generatedSourcesDirectory
        )
    }
}
