//
//  JSONValueSource.swift
//  SJSON
//
//  Created by Ben Johnson on 30/08/2016.
//
//

import Foundation

public protocol JSONTransformer {}

public struct JSONDefaultTransformer: JSONTransformer {}

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
