import XCTest
@testable import JSONKit

extension Date: JSONValueType {
    public static func map(value: Any, for transformer: JSONTransformer.Type) -> Date? {
        
        switch transformer {
        case is JSONDefaultTransformer.Type:
            guard let number = value as? NSNumber else {
                return nil
            }
            return Date(timeIntervalSince1970: number.doubleValue)
        case is CustomValueTransformer.Type:
            if let dateString = value as? String {
                return DateFormatterCache.sharedFormatter.RFC3339DateFormatter.date(from: dateString)
            }
            return nil
            
        default:
            return nil
        }
    }
}


class JSONKitTests: XCTestCase {
    
    enum DictionaryKeys: String, JSONKeySource {
        case food
    }
    
    func path() -> String {
        let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
        return parent
    }
    
    lazy var jsonDictionary: [String: AnyObject]  = {
        
        let jsonURL = URL(fileURLWithPath: self.path() + "/Supporting/test.json")
        print(jsonURL)
        let data = try! Data(contentsOf: jsonURL)
        let dictionary = (try! JSONSerialization.jsonObject(with: data, options: [])) as! [String: AnyObject]
        
        return dictionary
    }()
    
    var json: JSONObject<TestKeys> {
        return JSONObject<TestKeys>(dictionary: jsonDictionary)
    }
    
    enum Animal: Int {
        case cat
        case dog
        case fish
    }
    
    func testJSONObjectSourceFromData() {
        let jsonURL = URL(fileURLWithPath: self.path() + "/Supporting/test.json")
        let data = try! Data(contentsOf: jsonURL)
        
        let object = JSONObject<JSONDefaultKey>(data: data)
        XCTAssertNotNil(object)
    }
    
    func testRawValueFromJSONValue() {
        let rawValue = json[.integer].rawValue
        XCTAssertNotNil(rawValue)
    }
    
    func testRawObjectFromJSONValue() {
        let rawObject = json[.dictionary].rawObject
        XCTAssertNotNil(rawObject)
        XCTAssertNotNil(rawObject?[.food])
    }
    
    func testObjectFromJSONValue() {
        let object: JSONObject<DictionaryKeys>? = json[.dictionary].object()
        XCTAssertNotNil(object)
    }
    
    func testNilObjectFromJSONValue() {
        let object: JSONObject<DictionaryKeys>? = json[.numbers].object()
        XCTAssertNil(object)
    }
    
    func testNumberFromJSONValue() {
        let value:Int? = json[.integer].number()
        XCTAssertEqual(value, 7)
    }
    
    func testNumberValueFromJSONValue() {
        let value: Int = json[.invalidKey].number()
        XCTAssertEqual(value, 0)
    }
    
    func testDictionaryFromJSONValue() {
        let dictionary = json[.dictionary].dictionary
        XCTAssertNotNil(dictionary)
    }
    
    func testStringFromJSONValue() {
        let stringValue = json[.string].string
        XCTAssertEqual("Hello World", stringValue)
    }
    
    func testBoolFromJSONValue() {
        let boolValue = json[.bool].bool
        XCTAssertNotNil(boolValue)
        if let boolValue = boolValue {
            XCTAssertEqual(boolValue, true)
        }
    }
    
    func testIntFromJSONValue() {
        let intValue = json[.integer].int
        XCTAssertEqual(intValue, 7)
    }
    
    func testFloatFromJSONValue() {
        let floatValue = json[.decimal].float
        XCTAssertEqual(floatValue, 12.345)
    }
    
    func testDoubleFromJSONValue() {
        let doubleValue = json[.decimal].double
        XCTAssertEqual(doubleValue, 12.345)
    }
    
    func testIntArrayFromJSONValue() {
        let ints: [Int]? = json[.numbers].array()
        XCTAssertNotNil(ints)
        XCTAssertEqual(ints!, [5,10,15])
    }
    
    func testInvalidIntArrayFromJSONValue() {
        let ints: [Int]? = json[.strings].array()
        XCTAssertNil(ints)
    }
    
    func testFloatArrayFromJSONValue() {
        let decimals: [Float]? = json[.decimals].array()
        XCTAssertNotNil(decimals)
        if let decimals = decimals {
            XCTAssertEqual(decimals, [1.23, 5.55,9.0])
        }
    }
    
    func testDoublesArrayFromJSONValue() {
        let decimals: [Double]? = json[.decimals].array()
        XCTAssertNotNil(decimals)
        if let decimals = decimals {
            XCTAssertEqual(decimals, [1.23, 5.55,9.0])
        }
    }
    
    func testStringArrayFromJSONValue() {
        let strings: [String]? = json[.strings].array()
        XCTAssertNotNil(strings)
        if let strings = strings {
            XCTAssertEqual(strings, ["foo", "bar", "bacon"])
        }
    }
    
    func testEmptryStringArrayFromJSONValue() {
        let strings: [String] = json[.numbers].array()
        XCTAssertNotNil(strings)
        XCTAssertEqual(strings, [])
    }
    
    func testEmptyIntArrayFromJSONValue() {
        let ints: [Int] = json[.strings].array()
        XCTAssertNotNil(ints)
        XCTAssertEqual(ints, [])
    }
    
    func testEnumFromJSONValue() {
        let animal: Animal? = json[.animal].enum()
        XCTAssertEqual(animal, Animal.dog)
    }
    
    func testEnumArrayFromJSONValue() {
        let animals: [Animal]? = json[.animals].array()
        XCTAssertNotNil(animals)
        XCTAssertEqual(animals!, [Animal.cat, Animal.fish, Animal.dog])
    }
    
    func testCustomConvertibleFromJSONValue() {
        
            let dates: [Date]? = self.json[.dates].array()
            XCTAssertNotNil(dates)
            if let dates = dates {
                XCTAssertEqual(dates, [Date(timeIntervalSince1970: 1472722906), Date(timeIntervalSince1970: 1472722907)])
            }
    }
    
    func testIntValueFromJSONValue() {
        do {
            let intValue = try json[.integer].intValue()
            XCTAssertEqual(intValue, 7)
        } catch {
          //  XCTAssertEq
        }
    }
    
    func testMissingIntValue() {
        XCTAssertThrowsError(try json[.invalidKey].intValue(), "Should be missing value", { (error) in
        })
    }
    
    
    
    static var allTests : [(String, (JSONKitTests) -> () throws -> Void)] {
        return [
            ("testStringFromJSONValue", testStringFromJSONValue),
        ]
    }
}
