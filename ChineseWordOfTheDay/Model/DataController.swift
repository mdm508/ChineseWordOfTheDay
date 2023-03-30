//
//  DataController.swift
//  ChineseWordOfTheDay
//
//  Created by m on 2/14/23.
//

import CoreData
import Foundation
import SwiftCSV
import WidgetKit

class DataController {
    let container: NSPersistentContainer
    private lazy var managedObjectContext: NSManagedObjectContext = {
        return self.container.viewContext
    }()
    private lazy var privateContext: NSManagedObjectContext = {
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = self.managedObjectContext
        return childContext
    }()
    static private let defaults = UserDefaults.init(suiteName: Constants.appGroupId)!
    private(set) var currentWordIndex: Int {
        didSet {
            Self.writeIndexToUserDefaults(i: self.currentWordIndex)
            self.currentWord = self.getWord()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    @Published var currentWord: MyWord!
    init(inMemory: Bool = false){
        // Read currentWordIndex from UserDefaults
        self.currentWordIndex = Self.defaults.integer(forKey: Self.Constants.wordIndexKey)
        // Initialize container
        self.container = NSPersistentContainer(name: Self.Constants.dbName)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let storeURL = URL.storeURL(for: Self.Constants.appGroupId, databaseName:  Self.Constants.dbName)
            container.persistentStoreDescriptions.first!.url = storeURL
        }
        self.container.loadPersistentStores(completionHandler: {(storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        if !self.storeIsPopulated() {
            print("populating store")
            self.loadWordsFromCsvIntoDB()
            print("done")
        } else {
            print("loaded store from memory")
            self.currentWord = self.getWord()
        }
    }
}
extension DataController {
    func getWord() -> MyWord{
        return self.getWord(offset: self.currentWordIndex)
    }
    func getWord(offset: Int) -> MyWord{
        let request = NSFetchRequest<MyWord>(entityName: Self.Constants.EntityName.Word)
        request.fetchLimit = 1
        request.fetchOffset = offset
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.Constants.EntityName.Word)
        return try! self.managedObjectContext.count(for: request)
    }
}
extension DataController: ObservableObject {
    private func storeIsPopulated() -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.Constants.EntityName.Word)
        let count = try! self.managedObjectContext.count(for: request)
        return count > 0
        
    }
    static private func writeIndexToUserDefaults(i: Int){
        Self.defaults.set(i, forKey: Self.Constants.wordIndexKey)
    }
    private func loadWordsFromCsvIntoDB() {
        guard let csvBundleURL = Bundle.main.url(forResource: Self.Constants.csvName, withExtension: "csv") else {
            print("Unable to locate csv in bundle")
            return
        }
        let csv = try! CSV<Named>(url: csvBundleURL, delimiter: ",", loadColumns: false)
        privateContext.perform { [unowned self] in
            loadWords(from: csv, context: self.privateContext)
            if self.privateContext.hasChanges {
                do {
                    try  self.privateContext.save()
                }
                catch {
                    print("error saving child context")
                }
            }
            self.managedObjectContext.performAndWait {
                do {
                    try self.managedObjectContext.save()
                    self.currentWord = self.getWord()
                } catch {
                    print("problem writting changes to parent context")
                }
                
            }
        }
    }
    ///: Loads words into context from csv but does not save them
    private func loadWords(from csv: CSV<Named>, context: NSManagedObjectContext) {
        for i in 0..<csv.rows.count {
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
    }
    private func resetStore(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.Constants.EntityName.Word)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try self.managedObjectContext.execute(deleteRequest)
            Self.writeIndexToUserDefaults(i: 0)
        } catch let error as NSError {
            print("Problem resseting store")
            print(error)
        }
    }
    private func printRows(n: Int){
        for i in 0...n{
            print(self.getWord(offset: i).traditional!)
        }
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
extension DataController{
    private var amountToLoadSynchronously: Int{
        self.currentWordIndex + DataController.Constants.indexBuffer
    }
    struct Constants {
        static let defaults = UserDefaults.init(suiteName: appGroupId)!
        static let csvName = "pos_and_frequency"
        static let indexBuffer = 100
        static let wordIndexKey = "wordIndex"
        static let appGroupId = "group.matthedm.wod.chinese"
        static let dbName = "WordOfTheDay"
        struct EntityName {
            static let Word = String(describing: MyWord.self)
        }
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
