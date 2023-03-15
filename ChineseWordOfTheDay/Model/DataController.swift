//
//  DataController.swift
//  ChineseWordOfTheDay
//
//  Created by m on 2/14/23.
//

import CoreData
import Foundation
import SwiftCSV


class DataController {
    let container: NSPersistentContainer
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.container.viewContext
    }()
    var privateContext: NSManagedObjectContext
    @Published var currentWordIndex: Int {
        didSet {
            let userDefaults = UserDefaults(suiteName: Self.Constants.appGroupId)!
            userDefaults.set(self.currentWordIndex, forKey: Self.Constants.wordIndexKey)
        }
    }
    init(inMemory: Bool = false){
        // Read currentWordIndex from UserDefaults
        let userDefaults = UserDefaults(suiteName: Self.Constants.appGroupId)!
        let initialWordIndex = userDefaults.integer(forKey: Self.Constants.wordIndexKey)
        currentWordIndex = initialWordIndex
        
        // Initialize container
        self.container = NSPersistentContainer(name: Self.Constants.dbName)
            if inMemory {
//                storeDescription.type = NSInMemoryStoreType // Comment out if not testing
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            } else {
                let storeURL = URL.storeURL(for: Self.Constants.appGroupId, databaseName:  Self.Constants.dbName)
                container.persistentStoreDescriptions.first!.url = storeURL
            }
        self.container.loadPersistentStores(completionHandler: {(storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
            self.privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            self.privateContext.parent = self.container.viewContext
        if !self.storeIsPopulated() {
                print("populating store")
                self.loadWordsFromCsvIntoDB()
                print("done")
            } else {
                print("store is full already")
            }
            print("done with init")
    }
}
extension DataController {
    func getWord() -> MyWord{
        print(self.currentWordIndex)
        print("ftch")
        let request = NSFetchRequest<MyWord>(entityName: "MyWord")
        request.fetchLimit = 1
        request.fetchOffset = self.currentWordIndex
        let sortDescriptor = NSSortDescriptor(keyPath: \MyWord.percentageInFilms, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return try! self.managedObjectContext.fetch(request)[0]
    }
    func nextWord() -> Void {
        self.currentWordIndex = (self.currentWordIndex + 1) % self.wordCount()
    }
    func previousWord() -> Void {
        self.currentWordIndex = max(0, self.currentWordIndex - 1)
    }
    func wordCount() -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyWord")
        return try! self.managedObjectContext.count(for: request)
    }
}
extension DataController: ObservableObject {
    private func storeIsPopulated() -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyWord")
        let count = try! self.managedObjectContext.count(for: request)
        return count > 0
        
    }
    func loadWordsFromCsvIntoDB() {
        guard let csvBundleURL = Bundle.main.url(forResource: Self.Constants.csvName, withExtension: "csv") else {
            print("Unable to locate csv in bundle")
            return
        }
        let csv = try! CSV<Named>(url: csvBundleURL, delimiter: ",", loadColumns: false)
        // Load and save the some objects synchronously
        // This is needed because its possible that user user default value of currentWordIndex a number biger than 0
        // In most cases currentWordIndex will be small enough that user can experience benefit of a fast load.
        let viewContext = self.container.viewContext
        loadWords(from: csv, context: viewContext, startIndex: 0, endIndex: min(self.amountToLoadSynchronously, csv.rows.count))
        print("done with main sync loads")
        // Load and save the remaining objects asynchronously on a background thread
        privateContext.perform { [unowned self] in
            loadWords(from: csv, context: self.privateContext, startIndex: self.amountToLoadSynchronously, endIndex: csv.rows.count)
            try! self.privateContext.save()
                viewContext.performAndWait {
                    print("Saving to main contex")
                    try! viewContext.save()
                    print("done with all")
                }
            
            
        }
    }
    func loadWords(from csv: CSV<Named>, context: NSManagedObjectContext, startIndex: Int, endIndex: Int) {
        for i in startIndex..<endIndex {
            let row = csv.rows[i]
            let word = MyWord(context: context)
            word.traditional = row["Traditional"]
            word.simplified = row["Simplified"]
            word.pinyin = row["Pinyin"]
            word.percentageInFilms = Double(row["W-CD%"]!)!
            word.english = row["Eng.Tran."]
            word.allPos = row["All.PoS"]
            word.domPos = row["Dominant.PoS"]
        }
        print("saving")
        try! context.save()
    }
}
extension DataController{
    private var amountToLoadSynchronously: Int{
        self.currentWordIndex + DataController.Constants.indexBuffer
    }
    struct Constants {
        static let csvName = "pos_and_frequency"
        static let indexBuffer = 100
        static let wordIndexKey = "wordIndex"
        static let appGroupId = "group.matthedm.wod.chinese"
        static let dbName = "WordOfTheDay"
    }
}

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}


/* Csv fied names
 "Traditional",
 "Simplified",
 "Eng.Tran.",
 "Length",
 "Pinyin",
 "Pinyin.Input",
 "WCount",
 "W.million",
 "log10W",
 "W-CD",
 "W-CD%",
 "log10CD",
 "Dominant.PoS",
 "Dominant.PoS.Freq",
 "All.PoS",
 "All.PoS.Freq"
 */
