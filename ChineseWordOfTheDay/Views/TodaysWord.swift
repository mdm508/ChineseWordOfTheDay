//
//  TodaysWord.swift
//  ChineseWordOfTheDay
//
//  Created by m on 2/14/23.
//

import SwiftUI
import Combine
import WidgetKit

struct TodaysWord {
//    @FetchRequest(sortDescriptors: [SortDescriptor(\MyWord.percentageInFilms, order: .reverse)]) var words: FetchedResults<MyWord>
    @AppStorage("wordIndex", store: UserDefaults(suiteName: "group.matthedm.wod.chinese")) var currentWordIndex: Int = 0 {
        didSet {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    @EnvironmentObject private var dataController: DataController
}

extension TodaysWord: View {
    var body: some View {
        VStack{
            let word = self.dataController.getWord(at: self.currentWordIndex)
            WordView(word.traditional ?? "")
            Text(word.pinyin ?? "")
            Text(word.english ?? "")
            Spacer()
            Text(String(self.currentWordIndex))
            
       
            HStack{
                Button("prev",action: self.prevWord).disabled(self.currentWordIndex == 0)
                Button("next", action: self.nextWord)
            }
        }
            .onAppear{
                let refreshManager = RefreshManager.shared
                refreshManager.loadDataIfNeeded() { success in
                    if success {
                        self.nextWord()
                    }
                }
            }
    }
}
extension TodaysWord {
    func nextWord(){
        if self.currentWordIndex < self.dataController.wordCount(){
            self.currentWordIndex += 1
        }
    }
    func prevWord(){
        if self.currentWordIndex > 0{
            self.currentWordIndex -= 1
        }
    }
}

struct TodaysWord_Previews: PreviewProvider {
    static var previews: some View {
        TodaysWord()
    }
}
