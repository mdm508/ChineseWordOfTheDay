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
    let container = NSPersistentContainer(name: "WordOfTheDay")
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.container.viewContext
    }()
    init(){
        let storeURL = URL.storeURL(for: "group.matthedm.wod.chinese", databaseName: "WordOfTheDay")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores{ description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        if !self.storeIsPopulated(){
            print("populating stare")
            self.loadWordsFromCsvIntoDB()
        } else {
            print("store is full already")
        }
    }
}
extension DataController {
    func getWord(at index: Int) -> MyWord{
        let request = NSFetchRequest<MyWord>(entityName: "MyWord")
        request.fetchLimit = 1
        request.fetchOffset = index
        let sortDescriptor = NSSortDescriptor(keyPath: \MyWord.percentageInFilms, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return try! self.managedObjectContext.fetch(request)[0]
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
    func loadWordsFromCsvIntoDB(){
        guard let csvBundleURL =  Bundle.main.url(forResource: Self.Constants.csvName,
                                               withExtension: "csv") else {
            print("Unable to locate csv in bundle")
            return
        }
        let csv = try! CSV<Named>(url: csvBundleURL, delimiter: ",", loadColumns: false)
        try! csv.enumerateAsDict{dict in
            let word = MyWord(context: self.managedObjectContext)
            word.traditional = dict["Traditional"]
            word.simplified = dict["Simplified"]
            word.pinyin = dict["Pinyin"]
            word.percentageInFilms = Double(dict["W-CD%"]!)!
            word.english = dict["Eng.Tran."]
            word.allPos = dict["All.PoS"]
            word.domPos = dict["Dominant.PoS"]
            self.managedObjectContext.insert(word)
        }
        try! self.managedObjectContext.save()
                                               
                                            
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
