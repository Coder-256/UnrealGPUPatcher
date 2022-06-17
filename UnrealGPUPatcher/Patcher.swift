//
//  Patcher.swift
//  UnrealGPUPatcher
//
//  Created by Jacob Greenfield on 6/17/22.
//

import Foundation
import MachOKit

enum GPUType: CaseIterable, Identifiable {
    case intel, nvidia, other
    var id: Self { self }
}

func patch(url: URL, gpuType: GPUType) {}
