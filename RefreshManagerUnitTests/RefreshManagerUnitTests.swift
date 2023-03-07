//
//  RefreshManagerUnitTests.swift
//  RefreshManagerUnitTests
//
//  Created by m on 12/16/22.
//

import XCTest
import ChineseWordOfTheDay

final class RefreshManagerUnitTests: XCTestCase {
    func test_whenStoredDateIsMoreThanOneDayAwayFromCurrentDate_doesRefresh() throws {
         let today = DateComponents(calendar: Calendar(identifier: .gregorian),
                                       year: 1995,
                                       month: 3,
                                       day: 29).date!
        let manager = RefreshManager(defaults: MockUserDefaults(lastRefreshDate: today))
        // Manager should indicate that a refresh happened
        manager.loadDataIfNeeded(){success in XCTAssertTrue(success)}
        let updatedDate = manager.getCurrentRefreshDate() as! Date
        let calendar = Calendar.current
        XCTAssertEqual(calendar.startOfDay(for: updatedDate), calendar.startOfDay(for: Date()))
    }
    func test_refreshDateIsToday_doesNotRefresh(){
        let manager = RefreshManager(defaults: MockUserDefaults(lastRefreshDate: Date()))
        manager.loadDataIfNeeded(){success in XCTAssertFalse(success)}
        
    }
    func test_whenThereIsNoDateStoredInUserDefaults_doesRefresh(){
        
        let manager = RefreshManager(defaults: MockUserDefaults(lastRefreshDate: nil))
        manager.loadDataIfNeeded(){success in XCTAssertTrue(success)}
    }

}
