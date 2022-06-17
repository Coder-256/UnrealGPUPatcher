//
//  ContentView.swift
//  UnrealGPUPatcher
//
//  Created by Jacob Greenfield on 6/17/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var gpuType: GPUType = .intel
    @State private var isTargeted = false
    @ObservedObject var sharedLog = Log.shared

    var body: some View {
        VStack {
            Text("Drag an app here to patch!")
                .padding(.horizontal)

            Image(systemName: "app.dashed")
                .font(.system(size: 160, weight: .thin))
                .padding()
                .onDrop(of: [.fileURL], isTargeted: $isTargeted) { provider in
                    sharedLog.text = ""
                    provider[0].loadItem(forTypeIdentifier: UTType.url.identifier) { data, error in
                        if let error = error {
                            log("Drop error: \(error)")
                            return
                        }
                        guard let data = data as? Data,
                              let url = URL(dataRepresentation: data, relativeTo: nil) else {
                            log("Unable to get URL from drop source")
                            return
                        }
                        log("URL: \(url.absoluteString)")
                        guard let bundle = Bundle(url: url) else {
                            log("Unable to get bundle from URL")
                            return
                        }
                        guard let execURL = bundle.executableURL else {
                            log("Unable to get executable from bundle")
                            return
                        }
                        log("Exec URL: \(execURL.absoluteString)")
                        log("Starting patch...")
                        do {
                            try patch(url: execURL, gpuType: gpuType)
                        } catch {
                            log("Patching error: \(error)")
                        }
                    }
                    return true
                }
                .background(isTargeted ? Color.gray : Color.clear)

            Picker("Patched GPU Type", selection: $gpuType) {
                Text("Intel").tag(GPUType.intel)
                Text("NVIDIA").tag(GPUType.nvidia)
                Text("Other").tag(GPUType.other)
            }
            .pickerStyle(.radioGroup)

            TextEditor(text: .constant(sharedLog.text))
                .frame(width: 300, height: 100)
        }
        .padding()
        .fixedSize()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
