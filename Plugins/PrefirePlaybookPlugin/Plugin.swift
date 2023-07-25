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
                imports: configuration?.imports ?? [],
                generatedSourcesDirectory: context.pluginWorkDirectory)
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
                imports: configuration?.imports ?? [],
                generatedSourcesDirectory: context.pluginWorkDirectory)
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
        generatedSourcesDirectory: Path
    ) -> Command {
        Diagnostics.remark(
        """
        Prefire configuration
        Preview sources path: \(sources.string)
        Generated preview models path: \(generatedSourcesDirectory)/PreviewModels.generated.swift
        """
        )

        let templatesDirectory = executable.string.components(separatedBy: "Binaries").first! + "Templates"

        return Command.prebuildCommand(
            displayName: "Running Prefire",
            executable: executable,
            arguments: [
                "--templates",
                "\(templatesDirectory)/PreviewModels.stencil",
                "--sources",
                sources.string,
                "--output",
                "\(generatedSourcesDirectory)/PreviewModels.generated.swift",
                "--cacheBasePath",
                generatedSourcesDirectory.string,
                "--args",
                "imports=\(imports)",
            ],
            outputFilesDirectory: generatedSourcesDirectory
        )
    }
}
