//
//  ChineseDictionary.swift
//  ChineseWordOfTheDayTests
//
//  Created by m on 11/27/22.
//

import Foundation
import FMDB

struct ChineseDictionary{
    private var words: [Word]
}
extension ChineseDictionary{
    /// Reads words from database into an array
    init(){
        /// Finds url to database in the app support folder. If anything goes wrong it will just crash.
        func getDbURL() -> String {
            let fm = FileManager.default
            let suppurl = try! fm.url(for:.applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let dburl = suppurl.appendingPathComponent(Self.Constants.dbname)
            let dbExistsInAppSupportFolder = (try? dburl.checkResourceIsReachable()) ?? false
            if (!dbExistsInAppSupportFolder){
                guard let bundleURL =  Bundle.main.url(forResource: Self.Constants.bundleBaseName,
                                                       withExtension: Self.Constants.bundleExt) else {
                    print("couldn't find db inside the bundle")
                    return ""
                }
                try! fm.copyItem(at: bundleURL, to: dburl)
            }
            return dburl.description
        }
        /// Get all the words from the database and puth them in words array
        self.words = []
        let db = FMDatabase(path: getDbURL())
        db.open()
        if let rs = try? db.executeQuery("select Trad, Simp, Eng, Pinyin,  WMillion from words where DomPos='n' order by WMillion desc;", values: nil){
            while rs.next(){
                if let trad = rs["Trad"] as? String, let simp = rs["Simp"] as? String, let eng = rs["Eng"] as? String, let pinyin = rs["Pinyin"] as? String{
                    self.words.append(Word(traditional: trad, simplified: simp, pinyin: pinyin, english: eng))
                }
            }
        }
        db.close()
    }
    /// Return ith word at index in the dictionary.
    /// Guarantees the index is within the boundaries of the dictionary.
    func getWord(index: Int) -> Word {
        if index < 0 {
            return words[(words.count + index - 1 )]
        }
        return words[index % words.count]
    }
}
extension ChineseDictionary{
    struct Constants {
        static let dbname = "words.db"
        static let bundleBaseName = "words"
        static let bundleExt = ".db"
    }
}
