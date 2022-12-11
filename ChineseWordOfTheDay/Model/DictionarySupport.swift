//
//  DictionarySupport.swift
//  ChineseWordOfTheDay
//
//  Created by m on 12/8/22.
//

import Foundation
import SwiftUI
import WidgetKit

class DictionarySupport: ObservableObject {
    let dict: ChineseDictionary
    @AppStorage("wordIndex", store: UserDefaults(suiteName: "group.matthedm.wod.chinese")) var currentWordIndex: Int = 0
    var currentWord: Word {
        return self.dict.getWord(index: self.currentWordIndex)
    }
    init(){
        self.dict = ChineseDictionary()
    }
}
extension DictionarySupport {
    func nextWord(){
        moveIndexSetWord(moveForward: true)
    }
    func prevWord(){
        moveIndexSetWord(moveForward: false)
    }
    func wordIndex() -> String { self.currentWordIndex.description }
    private func moveIndexSetWord(moveForward: Bool){
        self.currentWordIndex += moveForward ? 1 : -1
        WidgetCenter.shared.reloadAllTimelines()
    }
}
