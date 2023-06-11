//
//  PreviewSampleData.swift
//  ChineseWordOfTheDay
//
//  Created by YU HSIN HO on 6/10/23.
//

/*
 Abstract:
 A view modifier for showing sample data in previews.
 */

import SwiftData
import words


@MainActor
let wordContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Word.self, ModelConfiguration(inMemory: true)
        )
        for word in SampleWords.contents {
            container.mainContext.insert(object: word)
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
