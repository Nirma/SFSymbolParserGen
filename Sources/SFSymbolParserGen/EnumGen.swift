//
//  EnumGen.swift
//  SFSymbolParserGen
//
//  Created by Nicholas Maccharoli on 2022/10/25.
//

import Foundation


final class EnumGen {
    
    static let indentation = 4
    
    static func padding(level: Int = 1) -> String {
        guard level > 0 else { return "" }
        
        return String(repeating: " ", count: EnumGen.indentation * level)
    }
    
    static func caseName(from components: [String]) -> String? {
        var result = components[0]
        
        if components.count >= 2 {
            result += components[1...].map { $0.capitalized }
                .joined()
        }
        
        return result
    }
    
    static func makeEnumCase(from symbol: SymbolData, indentationLevel: Int = 1, isNestedEnum: Bool = false) -> String {
        
        let caseName: String = isNestedEnum ? caseName(from: symbol.components) ?? "<FAILED>" : symbol.name
        if !caseName.isEmpty {
            return "\n" + EnumGen.padding(level: indentationLevel) + "case \(caseName) = \"\(symbol.identifierString)\""
        } else {
            return ""
        }
    }
    
    static func convertToEnum(_ symbols: [SymbolData]) -> String {
        var result: String = ""
        let variants = symbols.filter { !$0.components.isEmpty }
        let singleCase = symbols.first(where: { $0.components.isEmpty })
        
        if let singleCase = singleCase {
            let rawCase = makeEnumCase(from: singleCase)
            if !rawCase.isEmpty {
                result += "\n" + SymbolStringParser.sanitizeIdentifier(rawCase, isTypeName: false)
            }
        }
        
        if !variants.isEmpty {
            result += "\n"
            guard let name = variants.first?.name else { return result }
            let sanitizedName = SymbolStringParser.sanitizeIdentifier(name, isTypeName: true)
            result += "\n" + padding() + "enum \(sanitizedName) {"
            
            for symbol in variants {
                let rawCase = makeEnumCase(from: symbol, indentationLevel: 2, isNestedEnum: !symbol.components.isEmpty)
                result += SymbolStringParser.sanitizeIdentifier(rawCase, isTypeName: false)
            }
            result += "\n" + padding() + "}"
        }
        
        return result
    }
    
    static func outputEnum(name: String, symbolData: [SymbolData]) -> String {
        let symbolMap = makeMap(symbolData)
        let sortedKeys = symbolMap.keys.sorted()
        
        var result = ""
        
        for symbolKey in sortedKeys {
            if let currentSymbols = symbolMap[symbolKey] {
                result += convertToEnum(currentSymbols)
            }
        }
        
        return """
        enum \(name) {
        \(result)
        }

        """
    }
    static func makeMap(_ symbolData: [SymbolData]) -> [String: [SymbolData]] {
        var symbolDict = [String: [SymbolData]]()
        
        for symbolDatum in symbolData {
            if symbolDict[symbolDatum.name] == nil {
                symbolDict[symbolDatum.name] = []
            }
            
            symbolDict[symbolDatum.name]?.append(symbolDatum)
        }
        return symbolDict
    }
}
