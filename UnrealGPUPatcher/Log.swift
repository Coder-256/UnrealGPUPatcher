//
//  Log.swift
//  UnrealGPUPatcher
//
//  Created by Jacob Greenfield on 6/17/22.
//

import Foundation

@MainActor final class Log: ObservableObject {
    static var shared = Log()
    @Published var text = ""
}

func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    Task {
        await MainActor.run {
            Log.shared.text += items.map { "\($0)" }.joined(separator: separator) + terminator
        }
    }
}
