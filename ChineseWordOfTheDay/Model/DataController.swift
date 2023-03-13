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
            UserDefaults.standard.setValue(self.currentWordIndex, forKey: "wordIndex")
        }
    }
    init(){
        // Read currentWordIndex from UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.matthedm.wod.chinese")!
        let initialWordIndex = userDefaults.integer(forKey: "wordIndex")
        currentWordIndex = initialWordIndex
        // Initialize container
        container = NSPersistentContainer(name: "WordOfTheDay")
        privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = self.container.viewContext
        let storeURL = URL.storeURL(for: "group.matthedm.wod.chinese", databaseName: "WordOfTheDay")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.type = NSInMemoryStoreType // Comment out if not testing
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores{ description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
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
    private func getWord(at index: Int) -> MyWord{
        print("ftch")
        let request = NSFetchRequest<MyWord>(entityName: "MyWord")
        request.fetchLimit = 1
        request.fetchOffset = self.currentWordIndex
        let sortDescriptor = NSSortDescriptor(keyPath: \MyWord.percentageInFilms, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return try! self.managedObjectContext.fetch(request)[0]
    }
    func getWord() -> MyWord {
        return getWord(at: currentWordIndex)
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
        let amountToLoadSynchronously = self.currentWordIndex + 1
        let viewContext = self.container.viewContext
        loadWords(from: csv, context: viewContext, startIndex: 0, endIndex: min(amountToLoadSynchronously, csv.rows.count))
        // Load and save the remaining objects asynchronously on a background thread
        privateContext.perform { [unowned self] in
            loadWords(from: csv, context: self.privateContext, startIndex: amountToLoadSynchronously, endIndex: csv.rows.count)
            do {
                try self.privateContext.save()
                viewContext.performAndWait {
                    try! viewContext.save()
                    print("done with all")
                }
            } catch {
                print("Problem saving contexts")
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
        try! context.save()
    }
}
extension DataController{
    struct Constants {
        static let csvName = "pos_and_frequency"
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
