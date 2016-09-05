# JSONKit
JSONKit is a JSON mapping framework that makes JSON serialization code safer, cleaner and a lot more fun to write. What makes JSONKit awesome, is it's protocol orientated design combined with generics, which results in a powerful and customizable JSON serialization library.

## Features
- [x] Easily map value types, arrays and enums from JSON values
- [x] Supports custom types
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
With JSONKit you can write the above code like this:
```swift
var coordinates: [CLLocationCoordinate2D]?
if let geometryJSON: JSONObject<GEOObjectKey> = featureJSON[.geometry].object() {
    coordinates = geometryJSON[.coordinates].array()
}
```

## Integration
### Swift Package Manager
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
### Manually
You can also manually add JSONKit to your project by copying `JSONKit.swift` into your project.

## Getting Started
### Initalizing

JSONKit has strongly typed keys in order to improve safety. Keys are not accessed via a traditional string. Instead we define an enum with the collection of available keys.

```swift
// Enums must implement JSONKeySource
enum MovieInfoKey: String, JSONKeySource {
    case overview
    case title
    case runtime
    case releaseDate = "release_date"
}
```
Initalize a JSON Object for our keys
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
JSONKit supports chaining subscripts together in order to values.
```swift
// Chain several subscripts together to access specific values
let latitude = json[.geometry][.coordinates][0][0].double
```

#### Array mapping
JSONKit supports automatic mapping of JSON array into value types. JSONKit uses the array type of variable to determine how to map each value.
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
#### Throw access
JSONKit also has support for throwable access of values for `JSONObject`.
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
In order to add support to your own types, you need to implement `JSONValueType` on the type. This will give you array mapping support and for free.
```swift
// Add support for CLLocationCoordinate2D, by translating JSON numbers as a coordinate
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
Example for adding support for `Date`
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

let date = json[.createdAt].date
```
### Customizing how a value is mapped per document
JSONKit supports customizations for document specific behaviour, which is useful if you need to map json docs from different sources. For example you need to map two different date formats, like epoch or ISODate to `Date`, in this case the global extension on date won't work. This requires a use of a `JSONTransformer`.

We first need to define a struct that implements JSONTransformer
```swift
// Our CustomJSONTransformer
public struct CustomValueTransformer: JSONTransformer {}
```

Now we define a typealias for a `JSONCustomObject`, where we pass in our Keys and our new `JSONTransformer`.
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
```swift
let json = MyJSONObject<TestKeys>(dictionary: jsonDictionary)
let dates:[Date] = json[.timelineDate].array()
```
