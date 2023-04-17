//
//  RefreshManager.swift
//  ChineseWordOfTheDay
//
//  Created by m on 12/12/22.
// from https://stackoverflow.com/questions/50779564/call-a-function-one-time-per-day-at-a-specific-time-swift/50779939

import Foundation

class RefreshManager: NSObject {
    static let shared = RefreshManager()
    private let defaults: UserDefaults
    private let defaultsKey = "lastRefresh"
    private let calender = Calendar.current
    init(defaults: UserDefaults=UserDefaults.standard){
        self.defaults = defaults
        //used in case defaults has never been set before
        //avoids refresh before apps ready
        if defaults.object(forKey: defaultsKey) == nil {
            defaults.set(Date(), forKey: defaultsKey)

        }
    }
}
extension RefreshManager{
    /// Update last update time if needed.
    /// - Parameter completion: indicate wether a refresh occured or not
    func loadDataIfNeeded(completion: (Bool) -> Void) {
        if isRefreshRequired() {
            // update the old date to today
            defaults.set(Date(), forKey: defaultsKey)
            completion(true)
        } else {
            completion(false)
        }
    }
    func getCurrentRefreshDate() -> Any?{
        return defaults.object(forKey: defaultsKey)
    }
    private func isRefreshRequired() -> Bool {
        guard let lastRefreshDate = getCurrentRefreshDate() as? Date else {
            return true
        }
        if let diffInDaysBetweenLastRefreshAndToday = calender.dateComponents([.day], from: lastRefreshDate, to: Date()).day {
            return diffInDaysBetweenLastRefreshAndToday >= 1
        } else {
            return false
        }
    }
}
class MockUserDefaults: UserDefaults{
    var lastRefreshDate: Date?
    init(lastRefreshDate: Date?){
        self.lastRefreshDate = lastRefreshDate
        super.init(suiteName: nil)!
    }
    override func object(forKey defaultName: String) -> Any?{
        return self.lastRefreshDate
    }
    override func set(_ value: Any?, forKey defaultName: String){
        guard let date = value as? Date else {
            return
        }
        self.lastRefreshDate = date
        
    }
}
