//
//  Parser.swift
//  SFSymbolParserGen
//
//  Created by Nicholas Maccharoli on 2022/10/27.
//

import Foundation

public final class Parser {
    public static func parse(name: String, rawInput: String) -> String {
        let symbols = SymbolStringParser.parse(identifierText: rawInput)
        return EnumGen.outputEnum(name: name, symbolData: symbols)
    }
}
