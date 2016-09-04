import Foundation

/// A type that provides valid keys for accessing values for a JSON Object
public protocol JSONKeySource {
    var keyValue : String { get }
}

// Implement keyValue for Enum of Type == String to JSONKeySource
public extension RawRepresentable where RawValue == String {
    var keyValue: String {
        return rawValue
    }
}

/// A Default JSON Key to be used when accessing nested JSON Objects is not required
public struct JSONDefaultKey: JSONKeySource {
    public var keyValue: String {
        fatalError("Cannot use keys for \(self.self)")
    }
}

/// A type that acts as an identifier for how values should be transformed by `JSONCustomConvertible`
public protocol JSONTransformer {}

/// Default transformer used for `JSONValue`
public struct JSONDefaultTransformer: JSONTransformer {}

/// A type that acts a wrapper around a JSON value
public protocol JSONValueRepresentable {
    
    typealias RawValue = AnyObject?
    
    var rawValue: Self.RawValue { get }
    
  //  init(rawValue: Self.RawValue)
    
    associatedtype TransformerType: JSONTransformer = JSONDefaultTransformer
    
    init(rawValue: AnyObject?)
    
}

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





public protocol JSONValueSource: JSONValueRepresentable {
    
    associatedtype KeySource: JSONKeySource = JSONDefaultKey
    
    var key: String? { get }
    
    init(rawValue: AnyObject?, key: String)

}

public protocol JSONKeyProvider {
    
    var key: String? { get }
    
    init(rawValue: AnyObject?, key: String)
    
}


/// A type that is an container for a JSON Object
public protocol JSONObjectSource: JSONValueType {
    
    /// JSONKeySource for the object
    associatedtype KeySource: JSONKeySource
    
    /// Returned Type when accessing a value with key
    associatedtype ValueType
    
    var dictionary: [String: AnyObject] { get }
    
    init(dictionary: [String: AnyObject])
    
    init?(data: Data)
    
    
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
            
            return ValueType(rawValue: dictionary[key.keyValue], key: key.keyValue)
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

/// A generic container that implements JSONObjectSource
public struct JSONAnyObject<Value: JSONValueSource>: JSONObjectSource {
    
    public typealias KeySource = Value.KeySource
    
    // Update ValueType to include JSONKeySource
    public typealias ValueType = Value
    
    public let dictionary: [String : AnyObject]
    
    public init(dictionary: [String: AnyObject]) {
        self.dictionary = dictionary
    }
}

/// A type that implements all major features for `JSONValueSource`
protocol JSONValueProvider: JSONValueSource, JSONNumberProvider, JSONPrimitiveValueProvider, JSONAdditionalValueTypesProvider, JSONThrowable, JSONEnumProvider, JSONArrayProvider, JSONObjectProvider {}

/// Default container for `JSONValueProvider`
public struct JSONAnyValue<Keys:JSONKeySource, Transformer: JSONTransformer>: JSONValueProvider {
    
    public init(rawValue: AnyObject?, key: String) {
        self.rawValue = rawValue
        self.key = key
    }
    
    public init(rawValue: AnyObject?) {
        self.rawValue = rawValue
        // Source key is unknown, set to nil
        self.key = nil
    }

    /// Value that the wrapper contains
    public let rawValue: AnyObject?
    
    /// The source key which this value came from
    public let key: String?
    
    /// JSONKeySource to used with nested JSON Objects
    public typealias KeySource = Keys
    
    /// Sets the `JSONTransformer` type to generic parameter `Transformer`
    public typealias TransformerType = Transformer
    
}

/// A convenience JSON value wrapper that uses `JSONDefaultTransformer`
public typealias JSONValue<Keys: JSONKeySource> = JSONAnyValue<Keys, JSONDefaultTransformer>

/// A convenience JSON object container that uses `JSONValue`
public typealias JSONObject<Keys: JSONKeySource> = JSONAnyObject<JSONValue<Keys>>


/// Protocol that encapsulates all number value types
public protocol JSONNumber: JSONValueType {
    
    /// Casts NSNumber to `JSONNumber` type
    ///
    /// - parameter number: NSNumber object to be casted
    ///
    /// - returns: Value type with value of NSNumber
    static func from(number: NSNumber) -> Self
    
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

extension JSONValueRepresentable where Self: JSONThrowable {
    
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
    public func boolValue() throws -> Bool { return try unwrap(value: bool) }
    
    /// `JSONValueSource` value represented as a Int value
    ///
    /// - throws: `JSONError` if value is nil, or invalid cast
    ///
    /// - returns: Int value from JSON Value
    public func intValue() throws -> Int { return try unwrap(value: int) }
    
    /// `JSONValueSource` value represented as a Float value
    ///
    /// - throws: `JSONError` if value is nil, or invalid cast
    ///
    /// - returns: Float value from JSON Value
    public func floatValue() throws -> Float { return try unwrap(value: float) }
    
    /// `JSONValueSource` value represented as a Double value
    ///
    /// - throws: `JSONError` if value is nil, or invalid cast
    ///
    /// - returns: Double value from JSON Value
    public func doubleValue() throws -> Double { return try unwrap(value: double) }
    
    /// `JSONValueSource` value represented as a String value
    ///
    /// - throws: `JSONError` if value is nil, or invalid cast
    ///
    /// - returns: String from  current JSON Value
    public func stringValue() throws -> String { return try unwrap(value: string) }
}

extension JSONValueRepresentable where Self: JSONThrowable, Self: JSONAdditionalValueTypesProvider {
    
    public func int16Value() throws -> Int16 { return try unwrap(value: int16) }
    
    public func uInt16Value() throws -> UInt16 { return try unwrap(value: uInt16) }
    
    public func int32Value() throws -> Int32 { return try unwrap(value: int32) }
    
    public func uInt32Value() throws -> UInt32 { return try unwrap(value: uInt32) }
    
    public func int64Value() throws -> Int64 { return try unwrap(value: int64) }
    
    public func uint64Value() throws -> UInt64 { return try unwrap(value: uInt64) }
    
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
    
    public func arrayValue<T: RandomAccessCollection>() throws -> T where T.Iterator.Element: JSONValueType {
        return try _arrayValue()
    }
}

extension JSONValueSource where Self: JSONThrowable, Self: JSONArrayProvider, Self: JSONEnumProvider {
    
    public func arrayValue<T: RandomAccessCollection>() throws -> T where T.Iterator.Element: RawRepresentable, T.Iterator.Element.RawValue: JSONValueType {
        
        if let enums: [T.Iterator.Element] = array(), let collection = enums as? T {
            return collection
        }
        
        throw getJSONError()
    }
}

public protocol JSONPrimitiveValueProvider {
    
    var bool: Bool? { get }
    
    var int: Int? { get }
    
    var double: Double? { get }
    
    var float: Float? { get }
    
    var string: String? { get }
    
    var dictionary: [String: AnyObject]?  { get }
    
    var rawArray: [AnyObject]? { get }
    
}

public protocol JSONAdditionalValueTypesProvider {
    
    var int16: Int16? { get }
    
    var uInt16: UInt16? { get }
    
    var int32: Int32? { get }
    
    var uInt32: UInt32? { get }
    
    var int64: Int64? { get }
    
    var uInt64: UInt64? { get }
    
}

extension JSONValueSource where Self: JSONPrimitiveValueProvider, Self: JSONNumberProvider {
    
    public var bool: Bool? { return number() }
    
    public var int: Int? { return number() }
    
    public var double: Double? { return number() }
    
    public var float: Float? { return number() }
    
    public var string: String? {
        return rawValue as? String
    }
    
    public var dictionary: [String: AnyObject]? {
        return rawValue as? [String: AnyObject]
    }
}

extension JSONValueRepresentable where Self: JSONAdditionalValueTypesProvider, Self: JSONNumberProvider {
    
    public var int16: Int16? { return number() }
    
    public var uInt16: UInt16? { return number() }
    
    public var int32: Int32? { return number() }
    
    public var uInt32: UInt32? { return number() }
    
    public var int64: Int64? { return number() }
    
    public var uInt64: UInt64? { return number() }
    
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
            return Self(rawValue: dictionary?[key.keyValue], key: key.keyValue)
           // return Self(rawValue: dictionary?[key.keyValue])
        }
    }
}

/// A type that provides number versions of rawValue
public protocol JSONNumberProvider {
    
    var rawNumber: NSNumber? { get }
    
    func number<T: JSONNumber>() -> T?
    
    func number<T: JSONNumber>() -> T
    
}

extension JSONNumberProvider {
    public func number<T: JSONNumber>() -> T {
        if let num: T = number() {
            return num
        } else {
            return T.from(number: NSNumber(value: 0))
        }
    }
}

extension JSONValueRepresentable where Self: JSONNumberProvider {
    
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
}

public protocol JSONArrayProvider: JSONPrimitiveValueProvider {
    var rawArray: [AnyObject]? { get }
}

extension JSONValueRepresentable where Self: JSONArrayProvider {
    
    public var rawArray: [AnyObject]?
    {
        return rawValue as? [AnyObject]
    }
    
    func _array<T: RandomAccessCollection>(isAtomic: Bool = true) -> T? where T.Iterator.Element: JSONCustomConvertible {
        
        let transformer = TransformerType.self
        if let results =  rawArray?.flatMap({ (num) ->  T.Iterator.Element? in
            return T.Iterator.Element.map(value: num, for: transformer)
        }), !isAtomic || results.count == rawArray?.count {
            return results as? T
        } else {
            return nil
        }
    }
    
    
    func _arrayValue<T: RandomAccessCollection>(isAtomic atomic: Bool = true) -> T where T.Iterator.Element: JSONCustomConvertible {
        
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
            return Self(rawValue: rawArray?[index], key: "Index \(index)")
        }
    }
}

public protocol JSONEnumProvider {
    func `enum`<T: RawRepresentable>() -> T? where T.RawValue: JSONValueType
}

public extension JSONValueRepresentable where Self: JSONEnumProvider  {
    public func `enum`<T: RawRepresentable>() -> T? where T.RawValue: JSONValueType {
        
        if  let transformed = T.RawValue.map(value: rawValue, for: TransformerType.self) {
            return T(rawValue:  transformed)
        }
        
        return nil
    }
}

extension JSONValueRepresentable where Self: JSONArrayProvider, Self: JSONEnumProvider {
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

