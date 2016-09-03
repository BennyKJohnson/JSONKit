//
//  JSONKitTestHelper.swift
//  JSONKit
//
//  Created by Ben Johnson on 3/09/2016.
//
//

import Foundation
@testable import JSONKit

enum TestKeys: String, JSONKeySource {
    case integer
    case decimal
    case dates
    case string
    case bool
    case dictionary
    case numbers
    case strings
    case animals
    case subjects
    case animal
    case decimals
    case timelineDate
    case date
    case food
    case invalidKey
}

enum MyKeys: String, JSONKeySource {
    case test
}

class DateFormatterCache {
    static let sharedFormatter = DateFormatterCache()
    static var cache = [String : DateFormatter]()
    private init() {}
    
    func cachedFormatter(format: String) -> DateFormatter {
        if let cachedFormatter = DateFormatterCache.cache[format] {
            return cachedFormatter
        } else {
            let newFormatter = DateFormatter()
            newFormatter.dateFormat = format
            DateFormatterCache.cache[format] = newFormatter
            
            return newFormatter
        }
    }
    
    var RFC3339DateFormatter: DateFormatter {
        return cachedFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ")
    }
}


struct CustomValueTransformer: JSONTransformer {}

typealias MyJSONValue<Keys: JSONKeySource> = JSONCustomValue<Keys, CustomValueTransformer>

typealias MyJSONObject<Keys: JSONKeySource> = JSONCustomObject<MyJSONValue<Keys>>

extension JSONValueProvider where TransformerType == CustomValueTransformer {
    var date: Date? {
        return Date.map(value: rawValue, for: TransformerType.self)
    }
}

