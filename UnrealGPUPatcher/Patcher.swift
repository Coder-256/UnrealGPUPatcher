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

enum PatchError: Error {
    case invalidArch, noSymbolTable, cannotFindTargetSymbols
}

func patch(url execURL: URL, gpuType: GPUType) throws {
    let isIntelName = "__Z16IsRHIDeviceIntelv"
    let isNVIDIAName = "__Z17IsRHIDeviceNVIDIAv"
    let ret0 = [0x6A, 0x00, 0x58, 0xC3] // push 0x00, pop rax, ret
    let ret1 = [0x6A, 0x01, 0x58, 0xC3] // push 0x01, pop rax, ret

    let memoryMap = try MKMemoryMap(contentsOfFile: execURL)
    let macho = try MKMachOImage(name: nil, flags: [], atAddress: 0, inMapping: memoryMap)
    log("Macho: \(macho)")
    guard macho.architecture.cputype == mk_architecture_s.x86_64.cputype else {
        throw PatchError.invalidArch
    }
    guard let symbolTable = macho.symbolTable.value else {
        throw macho.symbolTable.error ?? PatchError.noSymbolTable
    }

    func findSymbol(named name: String, in table: MKSymbolTable) -> MKRegularSymbol? {
        return table.symbols
            .compactMap { $0 as? MKRegularSymbol }
            .first { $0.name.value?.string == name }
    }

    guard let isIntelSymbol = findSymbol(named: isIntelName, in: symbolTable),
          let isNVIDIASymbol = findSymbol(named: isNVIDIAName, in: symbolTable) else {
        throw PatchError.cannotFindTargetSymbols
    }

    log("found both symbols!")
}
