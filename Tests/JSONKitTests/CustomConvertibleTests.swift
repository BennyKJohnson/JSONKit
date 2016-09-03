//
//  CustomConvertibleTests.swift
//  SJSON
//
//  Created by Ben Johnson on 1/09/2016.
//
//

import XCTest
@testable import JSONKit


class CustomConvertibleTests: XCTestCase {

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
    
    func testCustomDate() {
        
        let json = MyJSONObject<TestKeys>(dictionary: jsonDictionary)
        let dates:[Date] = json[.timelineDate].array()
        XCTAssertNotNil(dates.first)
        let expectedDate = Date(timeIntervalSince1970: 1472782141.303575)
        XCTAssertEqual(Int(dates.first!.timeIntervalSince1970), Int(expectedDate.timeIntervalSince1970))
    }
    
    func testDateExtension() {
        let json = MyJSONObject<TestKeys>(dictionary: jsonDictionary)
        let date = json[.date].date
        
        let expectedDate = Date(timeIntervalSince1970: 1472782141.303575)
        XCTAssertEqual(Int(date?.timeIntervalSince1970 ?? 0), Int(expectedDate.timeIntervalSince1970))

    }
}
