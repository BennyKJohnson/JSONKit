//
//  JSONValueSource.swift
//  SJSON
//
//  Created by Ben Johnson on 30/08/2016.
//
//

import Foundation



/// A type that acts as an identifier for how values should be transformed by `JSONCustomConvertible`
public protocol JSONTransformer {}

/// Default transformer used for `JSONValue`
public struct JSONDefaultTransformer: JSONTransformer {}

/// A type that acts a wrapper around a JSON value
public protocol JSONValueSource {
    
    var rawValue: AnyObject? { get }
    
    init(rawValue: AnyObject?)
        
    associatedtype KeySource: JSONKeySource
     
    associatedtype JSONType = JSONValueType
    
    associatedtype TransformerType: JSONTransformer
    
}

public protocol JSONKeyProvider {
    var key: String? { get }
}
