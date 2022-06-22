//
//  UnrealGPUPatcherApp.swift
//  UnrealGPUPatcher
//
//  Created by Jacob Greenfield on 6/17/22.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct UnrealGPUPatcherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

func patch(providers: [NSItemProvider], gpuType: GPUType, callback: @escaping (Bool) -> ()) {
    providers[0].loadItem(forTypeIdentifier: UTType.url.identifier) { data, error in
        if let error = error {
            log("Drop error: \(error)")
            callback(false)
            return
        }
        guard let data = data as? Data,
              let url = URL(dataRepresentation: data, relativeTo: nil) else {
            log("Unable to get URL from drop source")
            callback(false)
            return
        }
        log("URL: \(url.absoluteString)")
        DispatchQueue.global(qos: .userInitiated).async {
            log("Starting patch...")
            do {
                try patch(url: url, gpuType: gpuType)
                callback(true)
                return
            } catch {
                log("Patching error: \(error)")
            }
            callback(false)
        }
    }
}
