//
//  JSONNumberTests.swift
//  SwiftJSON
//
//  Created by Ben Johnson on 17/08/2016.
//
//

import XCTest
@testable import JSONKit



class JSONNumberTests: XCTestCase {
    
    
    func testIntFromNumber() {
        let value = 5
        let number = NSNumber(value: value)
        XCTAssertEqual(value, Int.from(number: number))
    }
    
    func testInt8FromNumber() {
        let value: Int8 = 5
        let number = NSNumber(value: value)
        XCTAssertEqual(value, Int8.from(number: number))
    }
    
    func testUInt8FromNumber() {
        let value: UInt8 = 5
        let number = NSNumber(value: value)
        XCTAssertEqual(value, UInt8.from(number: number))
    }
    
    
    func testInt16FromNumber() {
        let value: Int16 = 10
        let number = NSNumber(value: value)
        XCTAssertEqual(value, Int16.from(number: number))
    }
    
    func testUInt16FromNumber() {
        let value: UInt16 = 5
        let number = NSNumber(value: value)
        XCTAssertEqual(value, UInt16.from(number: number))
    }
    
    func testInt32FromNumber() {
        let value: Int32 = -10
        let number = NSNumber(value: value)
        XCTAssertEqual(value, Int32.from(number: number))
    }
    
    func testUInt32FromNumber() {
        let value: UInt32 = 10
        let number = NSNumber(value: value)
        XCTAssertEqual(value, UInt32.from(number: number))
    }
    
    func testInt64FromNumber() {
        let value: Int64 = 10
        let number = NSNumber(value: value)
        XCTAssertEqual(value, Int64.from(number: number))
    }
    
    func testUInt64FromNumber() {
        let value: UInt64 = 10
        let number = NSNumber(value: value)
        XCTAssertEqual(value, UInt64.from(number: number))
    }
    
    func testFloatFromNumber() {
        let value: Float = 16.245
        let number = NSNumber(value: value)
        XCTAssertEqual(value, Float.from(number: number))
    }
    
    func testDoubleFromNumber() {
        let value: Double = 16.256
        let number = NSNumber(value: value)
        XCTAssertEqual(value, Double.from(number: number))
    }
    
    func testBoolFromNumberForTrueValue() {
        let value = 1
        let number = NSNumber(value: value)
        XCTAssertEqual(true, Bool.from(number: number))
    }
    
    func testBoolFromNumberForFalseValue() {
        let value = 0
        let number = NSNumber(value: value)
        XCTAssertEqual(false, Bool.from(number: number))
    }
    
    static var allTests : [(String, (JSONNumberTests) -> () throws -> Void)] {
        return [
            ("testIntFromNumber", testIntFromNumber),
        ]
    }
}
