//
//  JSONValueType.swift
//  SJSON
//
//  Created by Ben Johnson on 30/08/2016.
//
//

import Foundation

public protocol JSONCustomConvertible {
    
    static func map(value: Any, for transformer: JSONTransformer.Type) -> Self?
    
    static func transform(array: [Self]) -> [Self]?
    
    
}

extension JSONCustomConvertible {
    public static func transform(array: [Self]) -> [Self]? {
        return array
    }
}

public protocol JSONValueType: JSONCustomConvertible {}

extension String: JSONValueType {
    
    public static func map(value: Any, for transformer: JSONTransformer.Type) -> String? {
        return value as? String
    }
}

extension JSONObjectSource {
    public typealias PrimitiveType = [String: AnyObject]
    
}
