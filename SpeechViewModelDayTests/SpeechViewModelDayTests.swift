//
//  SpeechViewModelDayTests.swift
//  SpeechViewModelDayTests
//
//  Created by wonderland on 5/2/23.
//

import XCTest
import ChineseWordOfTheDay
import AVFoundation
import Combine

final class SpeechViewModelDayTests: XCTestCase {
    private var out: SpeechViewModel!
    private var subs: Set<AnyCancellable>!
    override func setUp(){
        self.out = SpeechViewModel()
        self.subs = Set<AnyCancellable>()
    }
    func testSpeak() throws {
        let expectation = XCTestExpectation(description: "Speech Complete")
        expectation.assertForOverFulfill = true
//        self.out.speak("Good morning to you I hope your feeling better baby")
        XCTAssertTrue(self.out.isSpeaking)
        wait(for: [expectation], timeout: 10)
        
    }


}
