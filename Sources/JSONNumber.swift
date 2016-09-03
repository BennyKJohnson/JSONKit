//
//  JSONNumber.swift
//  SJSON
//
//  Created by Ben Johnson on 30/08/2016.
//
//

import Foundation

public protocol JSONNumber: JSONValueType {
    
    static func from(number: NSNumber) -> Self
    
    associatedtype PrimitiveType = NSNumber
    
}

extension Int8: JSONNumber {
    
    public static func from(number: NSNumber) -> Int8 {
        return number.int8Value
    }
}

extension UInt8: JSONNumber {
    public static func from(number: NSNumber) -> UInt8 {
        return number.uint8Value
    }
}

extension Int16: JSONNumber {
    public static func from(number: NSNumber) -> Int16 {
        return number.int16Value
    }
}

extension UInt16: JSONNumber {
    public static func from(number: NSNumber) -> UInt16 {
        return number.uint16Value
    }
}

extension Int32: JSONNumber {
    public static func from(number: NSNumber) -> Int32 {
        return number.int32Value
    }
}

extension UInt32: JSONNumber {
    public static func from(number: NSNumber) -> UInt32 {
        return number.uint32Value
    }
}

extension Int64: JSONNumber {
    public static func from(number: NSNumber) -> Int64 {
        return number.int64Value
    }
}

extension UInt64: JSONNumber {
    public static func from(number: NSNumber) -> UInt64 {
        return number.uint64Value
    }
}

extension Int: JSONNumber {
    public static func from(number: NSNumber) -> Int {
        return number.intValue
    }
}

extension Float: JSONNumber {
    public static func from(number: NSNumber) -> Float {
        return number.floatValue
    }
}

extension Double: JSONNumber {
    public static func from(number: NSNumber) -> Double {
        return number.doubleValue
    }
}

extension Bool: JSONNumber {
    public static func from(number: NSNumber) -> Bool {
        return number.boolValue
    }
}

extension JSONNumber {
    
    public static func map(value: Any, for transformer: JSONTransformer.Type) -> Self? {
        if let number = value as? NSNumber {
            return Self.from(number: number)
        } else {
            return nil
        }
    }
}

