//
//  PreviewSampleData.swift
//  ChineseWordOfTheDay
//
//  Created by YU HSIN HO on 6/10/23.
//

import SwiftData
import Foundation


struct Containers {
    @MainActor
    static let wordContainer: ModelContainer = {
        do {
            copyDatabaseIfNeeded()
            let wordSchema = Schema([Word.self])
            let configuration = ModelConfiguration(schema: wordSchema)
            let container = try ModelContainer(for: Word.self, configuration)
            print(       container.configurations.description)
            //        WordLoader.loadWordsIntoContext(context: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create container")
        }
    }()
    @MainActor
    static let previewContainer: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: Word.self, ModelConfiguration(inMemory: true)
            )
            for word in WordLoader.previewContents {
                container.mainContext.insert(object: word)
            }
            try! container.mainContext.save()
            return container
        } catch {
            fatalError("Failed to create container")
        }
    }()
    
}
extension Containers {
    /// Ensures that when application is first run, a preloaded database will be copied into the Sandbox.
    /// For this function to work correctly, it must be that the store was previously set to journal mode.
    /// I did this by executing the sql command 'PRAGMA journal_mode = delete;' on the store.
    static   private func copyDatabaseIfNeeded() {
        let fileManager = FileManager.default
        guard let bundlePath = Bundle.main.path(forResource: "default", ofType: "store") else {
            print("Database file not found in the app bundle.")
            return
        }
        guard let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access the documents directory.")
            return
        }
        let destinationURL = documentsDirectoryURL.appendingPathComponent("default.store")
        // is the store already in documents? if so we dont need to copy it
        if !fileManager.fileExists(atPath: destinationURL.path) {
            do {
                try fileManager.copyItem(atPath: bundlePath, toPath: destinationURL.path)
                print("Database file copied to documents directory.")
            } catch {
                print("Error copying database file: \(error)")
            }
        } else {
            print("Database file already exists in the documents directory at: ")
            print(destinationURL.path())
        }
    }
    
}

/*
 WordLoaders main purpose is to read Json file which can then be used as a one time
 way to seed the database.
 
 Also it can be used to get previewContent needed by the in memory container
 
 */
struct WordLoader{
    static var contents = loadWordsFromJson()
    static var previewContents = loadWordsFromJson(30)
    
    static func loadWordsFromJson(_ limit:Int=0) -> [Word] {
        if let url = Bundle.main.url(forResource: "output", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let words = try decoder.decode([Word].self, from: jsonData)
                if limit > 0{
                    assert(limit < words.count)
                    let amountToDrop = words.count - limit
                    return words.dropLast(amountToDrop)
                }
                return words
                
            } catch let error as DecodingError {
                // Handle decoding errors
                print("Decoding error: \(error)")
            } catch let error {
                // Handle other errors
                print("Error: \(error)")
            }
        } else {
            print("JSON file not found.")
        }
        return []
        
    }
    static func loadWordsIntoContext(context: ModelContext){
        for word in Self.contents {
            context.insert(object: word)
        }
        try! context.save()
    }
}

