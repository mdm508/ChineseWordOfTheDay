//
//  ChineseWordOfTheDayApp.swift
//  ChineseWordOfTheDay
//
//  Created by m on 11/26/22.
//

import SwiftUI

@main
struct ChineseWordOfTheDayApp: App {

    private let dataController: DataController = DataController(inMemory: false)
    var body: some Scene {
        WindowGroup {
            TodaysWord()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)

        }
    }
}
