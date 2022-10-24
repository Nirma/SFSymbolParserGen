//
//  main.swift
//  SymbolGen
//
//  Created by Nicholas Maccharoli on 2022/10/28.
//

import Foundation
import SFSymbolParserGen
import ArgumentParser

class FileIO {
    
    /// Read file from disk or from STDIN if no filename is given
    static func read(filename: String?) throws -> Data? {
        if let filename = filename {
            return FileManager.default.contents(atPath: filename)
        }
        
        return nil
    }
    
    /// Write to standard out if no filename is given
    static func write(text: String, filename: String?) throws {
        if let fileName = filename {
            try text.write(toFile: fileName, atomically: true, encoding: .utf8)
        }
        
        guard let data = text.data(using: .utf8) else { return }
        try FileHandle.standardOutput.write(contentsOf: data)
    }
}

struct SymbolGen: ParsableCommand {
    @Option(help: "File holding symbol data")
    var inputFileName: String
    
    @Option(help: "Location to output file")
    var outputFileLocation: String?
    
    @Option(help: "Name of enum to output")
    var enumName: String
    
    func run() throws {
        guard
            let data = try FileIO.read(filename: inputFileName),
            let inputText = String(data: data, encoding: .utf8)
        else {
            try FileIO.write(text: "File does not exist", filename: nil)
            return
        }
        
        let symbolsEnum = Parser.parse(name: enumName, rawInput: inputText)
        try FileIO.write(text: symbolsEnum, filename: outputFileLocation)
    }
}

SymbolGen.main()

