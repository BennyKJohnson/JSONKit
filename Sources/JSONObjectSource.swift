//
//  JSONObjectSource.swift
//  SJSON
//
//  Created by Ben Johnson on 31/08/2016.
//
//

import Foundation

public protocol JSONObjectSource: JSONValueType {
    
    associatedtype KeySource: JSONKeySource
        
    associatedtype ValueType
    
    var dictionary: [String: AnyObject] { get }
    
    init(dictionary: [String: AnyObject])
    
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
