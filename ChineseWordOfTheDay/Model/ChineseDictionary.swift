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
    struct Constants {
        static let dbpath = "/Users/m/Developer/words.db"
    
    }
}
extension ChineseDictionary{
    /// Reads words from database into an array
    init(){
        self.words = []
        let db = FMDatabase(path: Self.Constants.dbpath)
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
    func getRandomWord() -> Word {
        if let word = self.words.randomElement() as Word? {
            return word
        } else {
            return Word(traditional: "uh", simplified: "oh", pinyin: "yup", english: "uh")
        }
    }
    /// Return ith word at index in the dictionary.
    /// Guarantees the index is within the boundaries of the dictionary.
    func getWord(index: Int) -> Word {
        if index < 0{
            return words[(words.count + index - 1 )]
        }
        return words[index % words.count]
    }
}
