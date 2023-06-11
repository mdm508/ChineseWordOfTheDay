//
//  ChineseWordOfTheDayApp.swift
//  ChineseWordOfTheDay
//
//  Created by m on 11/26/22.
//

import SwiftUI
import SwiftData

@main
struct ChineseWordOfTheDayApp: App {

    private let dataController: DataController = DataController(inMemory: false)
    var body: some Scene {
        WindowGroup {
            TestcView().modelContainer(wordContainer)

        }
    }
}
