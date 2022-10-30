//
//  SymbolStringParser.swift
//  SFSymbolParserGen
//
//  Created by Nicholas Maccharoli on 2022/10/23.
//

import Foundation

struct SymbolData: Equatable {
    let name: String
    let components: [String]
    let identifierString: String
}

final class SymbolStringParser {
    
    public static func parse(identifierText: String, separator: String = "\n") -> [SymbolData] {
        let lines = identifierText.components(separatedBy: "\n")
        return lines.compactMap { Self.convert($0) }
    }
    
    static func convert(_ input: String) -> SymbolData? {
        let componets = Self.components(from: input)
        let pairedComponents = Self.pairNumericValues(componets)
        
        if let name = pairedComponents.first {
            return SymbolData(
                name: name,
                components: pairedComponents.count > 1 ? Array(pairedComponents[1...]) : [],
                identifierString: input)
        }
        
        return nil
    }
    
    static func components(from identifier: String) -> [String] {
        return identifier.components(separatedBy: ".")
    }
    
    /// pair lone numbers with identifiers i.e: `["foo", "2", "bar"]` becomes `["foo2", "bar"]`
    static func pairNumericValues(_ input: [String]) -> [String] {
        var reversedItems = Array(input.reversed())
        
        var result = [String]()
        
        while let nextWord = reversedItems.first {
            let isNumeric = nextWord.allSatisfy { $0.isNumber }
            
            let dropCount: Int
            let nextResult: String
            
            if isNumeric && reversedItems.count > 1 {
                nextResult = reversedItems[1] + nextWord
                dropCount = 2
            } else {
                nextResult = nextWord
                dropCount = 1
            }
            
            result.append(nextResult)
            reversedItems = Array(reversedItems.dropFirst(dropCount))
        }
        
        return result.reversed()
    }
    
    static func sanitizeIdentifier(_ name: String, isTypeName: Bool) -> String {
        guard let firstLetter = name.first else {
            return name
        }
        
        let prefix: String
        
        if name.allSatisfy({ $0.isNumber }) {
            prefix = "number"
        } else if name.count == 1 && !firstLetter.isNumber {
            prefix = "letter"
        } else if firstLetter.isNumber && !name.allSatisfy({ $0.isNumber }) {
            prefix = "_"
        } else {
            prefix = ""
        }
        
        if prefix.isEmpty {
            return isTypeName ? name.capitalized : name
        } else {
            let pre = isTypeName ? prefix.capitalized : prefix
            return pre + name.capitalized
        }
    }
}
