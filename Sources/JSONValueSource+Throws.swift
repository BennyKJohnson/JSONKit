//
//  JSONValueSource+Throws.swift
//  SJSON
//
//  Created by Ben Johnson on 30/08/2016.
//
//

import Foundation

public enum JSONError: Error, CustomStringConvertible {
    case missingKey(String)
    case invalidCast(String)
    
    public var description: String {
        switch self {
        case .missingKey(let key):
            return "JSON Error: missing key '\(key)'"
        case .invalidCast(let key):
            return "JSON Error: invalid cast for '\(key)'"
        }
    }
}

/// A type that has throwable value functions
public protocol JSONThrowable: JSONKeyProvider {
    func getJSONError() -> JSONError
}

extension JSONValueSource where Self: JSONThrowable {
    
    public func getJSONError() -> JSONError {
        if rawValue == nil {
            return JSONError.missingKey(key ?? "UnknownKey")
        } else {
            return JSONError.invalidCast(key ?? "UnknownKey")
        }
    }
    
    public func unwrap<T>(value: T?) throws -> T {
        if let value = value {
            return value
        } else {
            throw getJSONError()
        }
    }
}

extension JSONValueSource where Self: JSONThrowable, Self: JSONPrimitiveValueProvider {

    
    /// `JSONValueSource` value represented as a Boolean value
    ///
    /// - throws: `JSONError` if value is nil, or invalid cast
    ///
    /// - returns: Boolean value from JSON Value
    public func boolValue() throws -> Bool {
        return try unwrap(value: bool)
    }
    
    /// `JSONValueSource` value represented as a Int value
    ///
    /// - throws: `JSONError` if value is nil, or invalid cast
    ///
    /// - returns: Int value from JSON Value
    public func intValue() throws -> Int {
       return try unwrap(value: int)
    }
    
    /// `JSONValueSource` value represented as a Float value
    ///
    /// - throws: `JSONError` if value is nil, or invalid cast
    ///
    /// - returns: Float value from JSON Value
    public func floatValue() throws -> Float {
        return try unwrap(value: float)
    }
    
    /// `JSONValueSource` value represented as a Double value
    ///
    /// - throws: `JSONError` if value is nil, or invalid cast
    ///
    /// - returns: Double value from JSON Value
    public func doubleValue() throws -> Double {
        return try unwrap(value: double)
    }
    
    /// `JSONValueSource` value represented as a String value
    ///
    /// - throws: `JSONError` if value is nil, or invalid cast
    ///
    /// - returns: String from  current JSON Value
    public func stringValue() throws -> String {
        return try unwrap(value: string)
    }
}

extension JSONValueSource where Self: JSONThrowable, Self: JSONNumberProvider {
    
    public func numberValue<T: JSONNumber>() throws -> T {
        return try unwrap(value: number())
    }
}

extension JSONValueSource where Self: JSONThrowable, Self: JSONObjectProvider {
    
    public func objectValue<T: JSONObjectSource>() throws -> T {
        return try unwrap(value: object())
    }
    
}


extension JSONValueSource where Self: JSONThrowable, Self: JSONArrayProvider {
    
    func _arrayValue<T: RandomAccessCollection>() throws -> T where T.Iterator.Element: JSONCustomConvertible {
        return try unwrap(value: _array(isAtomic: true))
    }
    
    func arrayValue<T: RandomAccessCollection>() throws -> T where T.Iterator.Element: JSONValueType {
        return try _arrayValue()
    }
}

extension JSONValueSource where Self: JSONThrowable, Self: JSONArrayProvider, Self: JSONEnumProvider {
    
    func arrayValue<T: RandomAccessCollection>() throws -> T where T.Iterator.Element: RawRepresentable, T.Iterator.Element.RawValue: JSONValueType {
        
        if let enums: [T.Iterator.Element] = array(), let collection = enums as? T {
            return collection
        }
        
        throw getJSONError()
    }
}
