//
//  JSONValueType.swift
//  SJSON
//
//  Created by Ben Johnson on 30/08/2016.
//
//

import Foundation
/// Implement this protocol on types to support casting from JSON value to the object
public protocol JSONCustomConvertible {
    
    /// Casts json value to Self
    ///
    /// - parameter value:       JSON Value to be casted
    /// - parameter transformer: The transformer type which can be used to modify the behaviour of the cast
    ///
    /// - returns: Initalized self from value, or if not successful, nil
    static func map(value: Any, for transformer: JSONTransformer.Type) -> Self?
    
}

public protocol JSONValueType: JSONCustomConvertible {}

extension String: JSONValueType {
    
    public static func map(value: Any, for transformer: JSONTransformer.Type) -> String? {
        return value as? String
    }
}

