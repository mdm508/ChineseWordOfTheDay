//
//  wordsTests.swift
//  wordsTests
//
//  Created by YU HSIN HO on 6/10/23.
//

import XCTest
import SwiftData
@testable import words

class wordsTests: XCTestCase {
    var words: [Word]!
    override func setUpWithError() throws {
        words = loadWordsFromJson()

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAllWordsLoaded() throws {
        let expectedWords = 13892
        XCTAssertEqual(self.words.count, expectedWords)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
