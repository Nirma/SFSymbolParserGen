//
//  SFSymbolParserGenTests.swift
//  SFSymbolParserGenTests
//
//  Created by Nicholas Maccharoli on 2022/10/23.
//

import XCTest
@testable import SFSymbolParserGen

final class SFSymbolParserGenTests: XCTestCase {

    func testPairNumericValues() {
        let input = ["foo", "2", "bar", "biz"]
        let expectedValue = ["foo2", "bar", "biz"]
        
        let result = SymbolStringParser.pairNumericValues(input)
        
        XCTAssert(expectedValue == result)
    }
    
    func testSanitizeIndetifierNumber() {
        XCTAssert(SymbolStringParser.sanitizeIdentifier("3", isTypeName: false) == "number3")
    }
    
    func testSanitizeIdentifierLetter() {
        XCTAssert(SymbolStringParser.sanitizeIdentifier("a", isTypeName: false) == "letterA")
    }
    
    func testSanitizeIdentifierLetterTypeName() {
        let result = SymbolStringParser.sanitizeIdentifier("a", isTypeName: true)
        let expectedValue = "LetterA"
        XCTAssert(result == expectedValue, "Expected: \(expectedValue) received: \(result)")
    }
    
    func testSanitizeIdentifierLetterName() {
        let result = SymbolStringParser.sanitizeIdentifier("a", isTypeName: false)
        let expectedValue = "letterA"
        XCTAssert(result == expectedValue, "Expected: \(expectedValue) received: \(result)")
    }
    
    func testSanitizeIdentifierPassthrough() {
        XCTAssert(SymbolStringParser.sanitizeIdentifier("circle", isTypeName: false) == "circle")
    }
    
    func testConvert() {
        let input = """
        arrow.triangle.2.circlepath.doc.on.clipboard
        bicycle.circle.fill
        """
        
        let expected = [
            SymbolData(
                name: "arrow",
                components: ["triangle2", "circlepath", "doc", "on", "clipboard"],
                identifierString: "arrow.triangle.2.circlepath.doc.on.clipboard"),
            SymbolData(
                name: "bicycle",
                components: ["circle", "fill"],
                identifierString: "bicycle.circle.fill")
        ]
    
        let result = SymbolStringParser.parse(identifierText: input)
        XCTAssert(result == expected)
    }
    
    func testParserTop() {
        let input = """
        externaldrive
        externaldrive.fill
        externaldrive.badge.plus
        externaldrive.fill.badge.plus
        externaldrive.badge.minus
        externaldrive.fill.badge.minus
        externaldrive.badge.checkmark
        externaldrive.fill.badge.checkmark
        externaldrive.badge.xmark
        externaldrive.fill.badge.xmark
        externaldrive.badge.person.crop
        """
        
        let expectedResult = """
        enum SFSymbols {

            case externaldrive = "externaldrive"/n

            enum Externaldrive {
                case fill = "externaldrive.fill"
                case badgePlus = "externaldrive.badge.plus"
                case fillBadgePlus = "externaldrive.fill.badge.plus"
                case badgeMinus = "externaldrive.badge.minus"
                case fillBadgeMinus = "externaldrive.fill.badge.minus"
                case badgeCheckmark = "externaldrive.badge.checkmark"
                case fillBadgeCheckmark = "externaldrive.fill.badge.checkmark"
                case badgeXmark = "externaldrive.badge.xmark"
                case fillBadgeXmark = "externaldrive.fill.badge.xmark"
                case badgePersonCrop = "externaldrive.badge.person.crop"
            }
        }
        
        """
        
        let result = Parser.parse(name: "SFSymbols", rawInput: input)
        print(result)
        
        XCTAssert(result == expectedResult)
    }
}
