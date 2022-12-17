//
//  RefreshManagerUnitTests.swift
//  RefreshManagerUnitTests
//
//  Created by m on 12/16/22.
//

import XCTest


final class RefreshManagerUnitTests: XCTestCase {
    func test_lastRerfreshDateOver24Hours_updatesRefresh() throws {
     let birthday = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: .current, year: 1995, month: 3, day: 29).date!
     let manager = RefreshManager(defaults: MockUserDefaults(lastRefreshDate: birthday))
        manager.loadDataIfNeeded(){success in XCTAssertTrue(success)}
        let updatedDate = manager.getCurrentRefreshDate() as! Date
        let secondsInADay: TimeInterval = 60*60*24
        XCTAssertLessThan(updatedDate.distance(to: Date()), secondsInADay)
    }
    func test_refreshDateIsToday_doesNotRefresh(){
        let manager = RefreshManager(defaults: MockUserDefaults(lastRefreshDate: Date()))
        manager.loadDataIfNeeded(){success in XCTAssertFalse(success)}
        
    }

}
