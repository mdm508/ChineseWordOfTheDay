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

    var body: some Scene {
        WindowGroup {
            TodaysWordView().modelContainer(Containers.wordContainer)

        }
    }
}
