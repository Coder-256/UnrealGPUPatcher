//
//  ContentView.swift
//  UnrealGPUPatcher
//
//  Created by Jacob Greenfield on 6/17/22.
//

import SwiftUI

struct ContentView: View {
    @State private var gpuType: GPUType = .intel
    @State private var isTargeted = false
    @State private var isPatching = false
    @State private var isSuccessful = true
    @State private var isShowingMark = false
    @ObservedObject var sharedLog = Log.shared
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Text("Drag an app here to patch!")
                        .padding(.horizontal)

                    ZStack {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 160, weight: .thin))
                            .padding()
                            .onDrop(of: isPatching ? [] : [.fileURL], isTargeted: $isTargeted) { providers in
                                isShowingMark = false
                                withAnimation { isPatching = true }
                                sharedLog.text = ""
                                patch(providers: providers, gpuType: gpuType) { success in
                                    isPatching = false
                                    isSuccessful = success
                                    withAnimation { isShowingMark = true }
                                }
                                return true
                            }
                            .background(isTargeted ? Color.gray : Color.clear)

                        Image(systemName: isSuccessful ? "checkmark.circle" : "xmark.circle")
                            .font(.system(size: 100))
                            .foregroundColor(isSuccessful ? Color.green : Color.red)
                            .opacity(isShowingMark ? 1 : 0)
                    }

                    Picker("Patched GPU Type", selection: $gpuType) {
                        Text("Intel").tag(GPUType.intel)
                        Text("NVIDIA").tag(GPUType.nvidia)
                        Text("Other").tag(GPUType.other)
                        Text("Remove patch").tag(GPUType.undo)
                    }
                    .pickerStyle(.radioGroup)
                }
                .padding(.vertical)

                if isPatching {
                    Color.gray.opacity(0.5)
                    ProgressView()
                }
            }

            TextEditor(text: .constant(sharedLog.text))
                .frame(width: 300, height: 100)
                .border(colorScheme == .light ? .black : .white, width: 1.0)
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
