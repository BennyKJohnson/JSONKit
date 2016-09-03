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
struct JSONDefaultKey: JSONKeySource {
    var keyValue: String {
        fatalError("Cannot use keys for \(self.self)")
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
protocol JSONValueProvider: JSONValueSource, JSONNumberProvider, JSONPrimitiveValueProvider, JSONThrowable, JSONEnumProvider, JSONArrayProvider, JSONObjectProvider {}


/// Default container for `JSONValueProvider`
public struct JSONAnyValue<Keys:JSONKeySource, Transformer: JSONTransformer>: JSONValueProvider {
    /// Value that the wrapper contains
    public let rawValue: AnyObject?
    
    /// The source key which this value came from
    public var key: String?
    
    /// JSONKeySource to used with nested JSON Objects
    public typealias KeySource = Keys
    
    /// Sets the `JSONTransformer` type to generic parameter `Transformer`
    public typealias TransformerType = Transformer
    
    public init(rawValue: AnyObject?) {
        self.rawValue = rawValue
    }
    
}

/// A convenience JSON value wrapper that uses `JSONDefaultTransformer`
public typealias JSONValue<Keys: JSONKeySource> = JSONAnyValue<Keys, JSONDefaultTransformer>

/// A convenience JSON object container that uses `JSONValue`
public typealias JSONObject<Keys: JSONKeySource> = JSONAnyObject<JSONValue<Keys>>
