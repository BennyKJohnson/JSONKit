//
//  JSONValueSource+Objects.swift
//  SJSON
//
//  Created by Ben Johnson on 30/08/2016.
//
//

import Foundation

public protocol JSONPrimitiveValueProvider {
    
    var bool: Bool? { get }
    
    var int: Int? { get }
    
    var double: Double? { get }
    
    var float: Float? { get }
    
    var string: String? { get }
    
    var dictionary: [String: AnyObject]?  { get }
    
    var rawArray: [AnyObject]? { get }
    
}

extension JSONValueSource where Self: JSONPrimitiveValueProvider, Self: JSONNumberProvider {
    
    public var bool: Bool? {
        return rawNumber?.boolValue
    }
    
    public var int: Int? {
        return rawNumber?.intValue
    }
    
    public var double: Double? {
        return rawNumber?.doubleValue
    }
    
    public var float: Float? {
        return rawNumber?.floatValue
    }
    
    public var string: String? {
        return rawValue as? String
    }
    
    public var dictionary: [String: AnyObject]? {
        return rawValue as? [String: AnyObject]
    }
    
}

public protocol JSONObjectProvider: JSONPrimitiveValueProvider {
    
    func object<T: JSONObjectSource>() -> T?
        
}

public extension JSONValueSource where Self: JSONObjectProvider {
    
    // Add property to return object with same key source
    
    public var rawObject: JSONAnyObject<Self>? {
        if let dictionary = dictionary {
            return JSONAnyObject<Self>(dictionary: dictionary)
        } else {
            return nil
        }
    }
 
    
    // Add Generic method to map a new key source
    public func object<T: JSONObjectSource>() -> T? {
        if let jsonObject = dictionary {
            return T(dictionary: jsonObject)
        } else {
            return nil
        }
    }
    
    public subscript(key: KeySource) -> Self {
        get {
            return Self(rawValue: dictionary?[key.keyValue])
        }
    }
}

public protocol JSONNumberProvider {

    var rawNumber: NSNumber? { get }
    
    func number<T: JSONNumber>() -> T?
    
}

extension JSONValueSource where Self: JSONNumberProvider {
    
    public var rawNumber: NSNumber? {
        return rawValue as? NSNumber
    }
    
    public func number<T: JSONNumber>() -> T? {
        if let value = rawNumber {
            return T.from(number: value)
        } else {
            return nil
        }
    }
    
     public func number<T: JSONNumber>() -> T {
        if let num: T = number() {
            return num
        } else {
            return T.from(number: NSNumber(value: 0))
        }
    }
}

public protocol JSONArrayProvider: JSONPrimitiveValueProvider {
     var rawArray: [AnyObject]? { get }
}

extension JSONValueSource where Self: JSONArrayProvider {
    
    public var rawArray: [AnyObject]?
    {
        return rawValue as? [AnyObject]
    }
    
    public func _array<T: RandomAccessCollection>(isAtomic: Bool = true) -> T? where T.Iterator.Element: JSONCustomConvertible {
       
        let transformer = TransformerType.self
        if let results =  rawArray?.flatMap({ (num) ->  T.Iterator.Element? in
            return T.Iterator.Element.map(value: num, for: transformer)
        }), !isAtomic || results.count == rawArray?.count {
            return results as? T
        } else {
            return nil
        }
    }
    
    
    public func _arrayValue<T: RandomAccessCollection>(isAtomic atomic: Bool = true) -> T where T.Iterator.Element: JSONCustomConvertible {
        
        if let values:T = _array(isAtomic: atomic) {
            return values
        } else {
            return [] as! T
        }
    }
    
    public func array<T: RandomAccessCollection>(isAtomic: Bool = true) -> T? where T.Iterator.Element: JSONValueType {
        return _array(isAtomic: isAtomic)
    }
    
    public func array<T: RandomAccessCollection>(isAtomic: Bool = true) -> T where T.Iterator.Element: JSONValueType {
        return _arrayValue(isAtomic: isAtomic)
    }
}

extension JSONValueSource where Self: JSONArrayProvider {
   public subscript(_ index: Int) -> Self {
        get {
            return Self(rawValue: rawArray?[index])
        }
    }
}

public protocol JSONEnumProvider {
    func `enum`<T: RawRepresentable>() -> T? where T.RawValue: JSONValueType
}

public extension JSONValueSource  {
    public func `enum`<T: RawRepresentable>() -> T? where T.RawValue: JSONValueType {
        
        if  let transformed = T.RawValue.map(value: rawValue, for: TransformerType.self) {
            return T(rawValue:  transformed)
        }
    
        return nil
    }
}

extension JSONValueSource where Self: JSONArrayProvider, Self: JSONEnumProvider {
    // Support an array of enums
    func array<T: RandomAccessCollection>(isAtomic: Bool = true) -> T? where T.Iterator.Element: RawRepresentable, T.Iterator.Element.RawValue: JSONValueType {
        if let array: [T.Iterator.Element.RawValue] = array(isAtomic: true) {
            
            let enumArray = array.flatMap({ (element) -> T.Iterator.Element? in
                return T.Iterator.Element(rawValue: element)
            })
            
            return enumArray as? T
        }
        
        return nil
    }
}






