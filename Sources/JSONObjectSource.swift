//
//  JSONObjectSource.swift
//  SJSON
//
//  Created by Ben Johnson on 31/08/2016.
//
//

import Foundation

/// A type that is an container for a JSON Object 
public protocol JSONObjectSource: JSONValueType {
    
    /// JSONKeySource for the object
    associatedtype KeySource: JSONKeySource
    
    /// Returned Type when accessing a value with key
    associatedtype ValueType
    
    var dictionary: [String: AnyObject] { get }
    
    init(dictionary: [String: AnyObject])
    

    /// Required to access value for key
    ///
    /// - parameter key: a key for the value
    ///
    /// - returns: ValueType for value at key
    subscript(key: KeySource) -> ValueType { get }
    
}

extension JSONObjectSource where ValueType: JSONValueSource {
    
    public subscript(key: KeySource) -> ValueType {
        get {
            return ValueType(rawValue: dictionary[key.keyValue])
        }
    }
}

public extension JSONObjectSource {
    
    public static func map(value: Any, for transformer: JSONTransformer.Type) -> Self? {
        if let dictionary = value as? [String: AnyObject] {
            return Self(dictionary: dictionary)
        }
        return nil
    }
    
    public init?(data: Data) {
        guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: AnyObject] else {
            return nil
        }
        
        self.init(dictionary: jsonDictionary)
    }
}
