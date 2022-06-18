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
    case invalidArch, noSymbolTable, cannotFindTargetSymbol, missingSection
}

func hex(_ n: UInt64) -> String {
    return "0x" + String(format: "%02X", n)
}

func patch(url execURL: URL, gpuType: GPUType) throws {
    // First, back up!
    let backupURL = execURL.appendingPathExtension("bak")
    log("Backup URL: \(backupURL.absoluteString)")
    if !FileManager.default.fileExists(atPath: backupURL.path) {
        try FileManager.default.copyItem(at: execURL, to: backupURL)
    }
    try? FileManager.default.removeItem(at: execURL)
    try FileManager.default.copyItem(at: backupURL, to: execURL)

    let memoryMap = try MKMemoryMap(contentsOfFile: backupURL)
    let macho = try MKMachOImage(name: nil, flags: [], atAddress: 0, inMapping: memoryMap)
    log("Macho: \(macho)")
    guard macho.architecture.cputype == mk_architecture_s.x86_64.cputype else {
        throw PatchError.invalidArch
    }
    guard let symbolTable = macho.symbolTable.value else {
        throw macho.symbolTable.error ?? PatchError.noSymbolTable
    }

    let isIntelSymbolName = "__Z16IsRHIDeviceIntelv"
    let isNVIDIASymbolName = "__Z17IsRHIDeviceNVIDIAv"
    let ret0: [UInt8] = [0x6A, 0x00, 0x58, 0xC3] // push 0x00, pop rax, ret
    let ret1: [UInt8] = [0x6A, 0x01, 0x58, 0xC3] // push 0x01, pop rax, ret

    let handle = try FileHandle(forWritingTo: execURL)
    try patchSymbol(named: isIntelSymbolName,
                    in: symbolTable,
                    patch: gpuType == .intel ? ret1 : ret0,
                    handle: handle)
    try patchSymbol(named: isNVIDIASymbolName,
                    in: symbolTable,
                    patch: gpuType == .nvidia ? ret1 : ret0,
                    handle: handle)
    log("Patch successful!")
}

func patchSymbol(named name: String, in table: MKSymbolTable, patch: [UInt8], handle: FileHandle) throws {
    let symbol = table.symbols
        .compactMap { $0 as? MKRegularSymbol }
        .first { $0.symbolType == .section && $0.name.value?.string == name }

    guard let symbol = symbol else {
        throw PatchError.cannotFindTargetSymbol
    }
    log("Symbol:")
    log(symbol.debugDescription)
    guard let section = symbol.section.value else {
        throw PatchError.missingSection
    }
    log("Section:")
    log(section.debugDescription)
    let symbolFileOffset = section.fileOffset + (symbol.value - section.vmAddress)
    log("Symbol file offset: \(hex(symbolFileOffset))")
    try handle.seek(toOffset: symbolFileOffset)
    try handle.write(contentsOf: patch)
    log("Patched symbol at \(hex(symbolFileOffset))")
}
