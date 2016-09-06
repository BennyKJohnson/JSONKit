# JSON Kit
JSON Kit is a JSON mapping framework that makes JSON serialization code safer, cleaner and a lot more fun to write. It combines protocol oriented design with generics to create a powerful interface for working with JSON in Swift.

## Features
- [x] Strongly typed keys, leverage the compiler to autocomplete keys and validate keys
- [x] Easily map value types, arrays and enums from JSON values
- [x] Throwable value access, avoid large if let/guard blocks
- [x] Easily add support for custom types
- [x] Modular, extend or modify behaviour of mapping

## Why it is awesome
Consider the following JSON serialization code to extract coordinates from GEOJSON data.
```swift
var coordinates: [CLLocationCoordinate2D]?
if let geometryDict = jsonDictionary["geometry"] as? [String: AnyObject] {
    if let coordinateValues = geometryDict["coordinates"] as? [[Double]] {
        coordinates = coordinateValues.map({ (coordinateValue) -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(latitude: coordinateValue[0], longitude: coordinateValue[1])
        })
    }
}
```
With JSON Kit you can write the above code like this:
```swift
var coordinates: [CLLocationCoordinate2D]?
if let geometryJSON: JSONObject<GEOObjectKey> = featureJSON[.geometry].object() {
    coordinates = geometryJSON[.coordinates].array()
}
```
## Getting Started
### Initalizing

JSON Kit has strongly typed keys in order to improve safety. Keys are not accessed via a traditional string. Instead we define an enum with the collection of available keys.

```swift
// Enums must implement JSONKeySource
enum MovieInfoKey: String, JSONKeySource {
    case overview
    case title
    case runtime
    case releaseDate = "release_date"
}
```
This may seem inconvenient at first, but provides many benefits over a stringly typed approach, such as autocomplete, compiler verified and also encourages good practice through grouping related keys.

Initalize a JSON Object for our keys, `JSONObject` provides the primary interface for working with a dictionary of key/value pairs.
```swift
let json = JSONObject<MovieInfoKey>(data: dataFromNetwork)
```

### Accessing Values
#### Value Types
```swift
//Getting a string from a JSON Object
let overview = json[.overview].string
```
```swift
//Getting a double from a JSON Object
let runtime = json[.runtime].double
```

#### JSON Object mapping
If you would like to continue using your current key set, you can use `rawObject`
```swift
let geometryJSON = json[.geometry].rawObject
```
To map JSON Object against another key set, do the following
```swift
if let geometryJSON: JSONObject<GEOObjectKey> = featureGEOJSON[.geometry].object() {
      let geometryType = geometryJSON[.type].string
}
```
#### Subscripts
You can also chain subscripts together in order to access values.
```swift
// Chain several subscripts together to access specific values
// Note that the keys available are restricted to your current key set
let latitude = json[.geometry][.coordinates][0][0].double
```

#### Array mapping
Automatically map a JSON array into an array of value types. JSON Kit uses the array type of variable to determine how to map each value.
```swift
//Getting an array of strings from a JSON Object
let names: [String]? = json[.names].array()
```
```swift
//Getting an array of doubles from a JSON Object
let coordinates: [Double]? = json[.coordinates].array()
```
```swift
//Getting an array of UInt8 from a JSON Object
let colors8Bit: [UInt8]? = json[.colors].array()
```
If you would just prefer an empty array over an optional array, just declare a non optional array
```swift
// Array of values, or if nil, an empty array
let names: [String] = json[.names].array()
```
Mapping an array of JSON Objects to a key set
```swift
for featureGEOJSON in json[.features].array() as [JSONObject<GEOFeatureKey>] {
    // ...
}
```
Array mapping is atomic, meaning if one value can't be mapped, the whole operation fails and nil or empty array is returned instead.
It's possible to change this behaviour using the `isAtomic` parameter for `array`.
```swift
// Will return any values successfully converted
numbers = json[.numbers].array(isAtomic: false)
```
#### Enum Mapping
JSONKit also supports automatic enum mapping for raw value enums.
```swift
enum ReleaseStatus: String {
    case pending
    case released
}
// Maps the JSON String Value to the corresponding enum case
let status: ReleaseStatus? = json[.status].enum()
```
You can even automatically map an array of values to an array of enums
```swift
let statuses: [ReleaseStatus] = json[.statuses].array()
```
#### Throw value access
Throwable functions are named [type]Value, for example  `arrayValue`, `enumValue` or `objectValue`. These functions throw `JSONError` if the value doesn't exist or it can't convert to the required value, instead of returning nil.
```swift
struct Movie {

    let overview: String
    let runtime: Double

    init?(json: JSONObject<MovieInfoKey>) throws {

            overview = try json[.overview].stringValue()
            runtime = try json[.runtime].numberValue()

    }
}
```
## Customizing
### Custom Value
In order to add support to your own types, you need to implement `JSONValueType` on the type. This will give you array mapping support for free.
```swift
// Add support for CLLocationCoordinate2D, by translating JSON numbers to a coordinate
extension CLLocationCoordinate2D: JSONValueType {
    public static func map(value: Any, for transformer: JSONTransformer.Type) -> CLLocationCoordinate2D? {
        if let coordinateValues = value as? [NSNumber],coordinateValues.count == 2 {
            return CLLocationCoordinate2D(latitude: coordinateValues[0].doubleValue, longitude: coordinateValues[1].doubleValue)
        }
        return nil
    }
}

  let coordinates: [CLLocationCoordinate2D] = featureGEOJSON[.geometry][.coordinates].array()
```
Another example of custom types, adding support for `Date`
```swift
extension Date: JSONValueType {
    public static func map(value: Any, for transformer: JSONTransformer.Type) -> Date? {
        if let epoch = value as? Double {
            return Date(timeIntervalSince1970: epoch)
        }
        return nil
    }
}

// Define an extension for a convenience property
extension JSONValueSource {
    var date: Date? {
        return mapped()
    }
}

// Get a date value
let date = json[.createdAt].date
```
### Mapping different formats to the same type
Above you saw an example of converting an epoch date directly to `Date`. If you need to support multiple representations of the same type, you will need to rely on a `JSONTransformer` to modify how values are mapped. For example you may need to support both epoch and ISODates to `Date`.

We first need to define a struct that implements `JSONTransformer`, this type will act as an identifier for the `map` function.
```swift
// Our CustomJSONTransformer
public struct CustomValueTransformer: JSONTransformer {}
```

Now we define a typealias for a `JSONCustomObject`, where we pass in our Keys and our new `JSONTransformer`. We will use this object to access values. A general rule to follow is define a `JSONCustomObject` and `JSONTransformer` per document.
```swift
typealias MyJSONObject<Keys: JSONKeySource> = JSONCustomObject<Keys, CustomValueTransformer>
```
 Finally implement `JSONValueType` on your type. Switching on the `transformer` type.
```swift
extension Date: JSONValueType {
    public static func map(value: Any, for transformer: JSONTransformer.Type) -> Date? {

        switch transformer {
        case is CustomValueTransformer.Type:
            if let dateString = value as? String {
                return DateFormatterCache.sharedFormatter.RFC3339DateFormatter.date(from: dateString)
            }
            return nil

        default:
            guard let number = value as? NSNumber else {
              return nil
            }
            return Date(timeIntervalSince1970: number.doubleValue)
        }
    }
}
```
Now we use our new `MyJSONObject` as an interface, any values accessed will be mapped using the custom transformer.
```swift
let json = MyJSONObject<TestKeys>(dictionary: jsonDictionary)
// All date values using MyJSONObject are decoded from ISODate
let dates:[Date] = json[.timelineDate].array()
```

### Verify collections
JSON Kit allows you to modify an extracted collection before it is returned. This is useful if you need to verify a collection of a certain type.

```swift
extension String {
    public static func verify(array: [String], for transformer: JSONTransformer.Type) -> [String]? {
      // Check if the string array is not an array with an empty string [" "]
        if let firstElement = array.first, array.count == 1 {
            if firstElement.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
              // Not a valid collection
                return nil
            }
        }
        return array
    }
}
```
## Integration
### Manually (recommended)
 Add JSON Kit to your project by copying `JSONKit.swift` into your project. Having JSON Kit in the same module will allow you to modify JSON Kit behaviour that is defined with existing protocol extensions.

### Swift Package Manager
You can add JSON Kit as a framework, however you won't be able to modify existing protocol extensions.

Add `JSONKit` to your `Package.swift`:
```swift
import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .Package(url: "https://github.com/BennyKJohnson/JSONKit.git", majorVersion: 0, minor: 2)
    ]
)
```
Import the JSONKit library:
```swift
import JSONKit
```
