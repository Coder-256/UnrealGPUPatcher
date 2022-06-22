//
//  PatchCLI.swift
//  patch
//
//  Created by Jacob Greenfield on 6/21/22.
//

import Foundation
import ArgumentParser

func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    print(items, separator: separator, terminator: terminator)
}

extension GPUType: ExpressibleByArgument {}

@main
struct Patch: ParsableCommand {
    @Argument(help: "Path to the app to patch; should end in '.app'.")
    var path: String

    @Option(name: .shortAndLong, help: """
The GPU type to emulate ('intel', 'nvidia', 'other', or 'undo'). Pass 'undo' to remove the patch.
""")
    var gpuType: GPUType = .intel

    func run() throws {
        print(GPUType.allValueStrings)
        try patch(url: URL(fileURLWithPath: path), gpuType: gpuType)
    }
}
