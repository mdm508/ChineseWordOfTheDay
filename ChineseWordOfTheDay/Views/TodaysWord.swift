//
//  TodaysWord.swift
//  ChineseWordOfTheDay
//
//  Created by m on 2/14/23.
//

import SwiftUI
import Combine
import WidgetKit
import CoreData


struct TodaysWord {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dataController: DataController
    @State var currentIndex: Int = 0 {
        didSet {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    @State var subscriptions = Set<AnyCancellable>()
    @State var word: MyWord?
}

extension TodaysWord: View {
    var body: some View {
        VStack{
            if let word = self.word {
                WordView(word.traditional ?? "")
                Text(word.pinyin ?? "")
                Text(word.english ?? "")
                Spacer()
                Text(String(self.currentIndex))
                HStack{
                    Button("prev",action: {self.dataController.previousWord()}).disabled(self.currentIndex == 0)
                    Button("next", action: {self.dataController.nextWord()})
                }
            } else {
                Text("Initializing database")
            }
        }
            .onAppear{
                // set up subscription to changes in index
                self.dataController.$currentWordIndex.sink{[self]newIndex in
                    self.currentIndex = newIndex
                    self.word = self.dataController.getWord()
                }.store(in: &self.subscriptions)
                
                let refreshManager = RefreshManager.shared
                refreshManager.loadDataIfNeeded() { itIsTomorrow in
                    if itIsTomorrow {
                        self.dataController.nextWord()
                    }
                }
            }
    }
}

struct TodaysWord_Previews: PreviewProvider {
    static var previews: some View {
        TodaysWord()
    }
}