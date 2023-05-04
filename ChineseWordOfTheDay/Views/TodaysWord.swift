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
import AVFoundation

struct TodaysWord {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dataController: DataController
    @State var currentIndex: Int = 0
    @State var subscriptions = Set<AnyCancellable>()
    @State var word: MyWord?
    var gridItems: [GridItem] {
           [            GridItem(.flexible()),            GridItem(.flexible())        ]
       }
}

extension TodaysWord: View {
    var body: some View {
        VStack{
            if let word = self.word {
                WordView(word.traditional ?? "")
                HStack{
                    Spacer()
                    Text(word.pinyin ?? "")
                    Spacer()
                    if let trad = word.traditional {
                        PlayButton(textToSpeak: trad, lang: LanguageCode.chineseTaiwan )
                    }
                }
                HStack{
                    Spacer()
                    Text(word.english ?? "")
                    Spacer()
                    if let english = word.english {
                        PlayButton(textToSpeak: english, lang: LanguageCode.english)
                    }
                }
                Spacer()
                Text(String(self.dataController.currentWordIndex))
                HStack{
                    Button("<<", action: {
                        for _ in 1...20{
                            if self.currentIndex >= 0{
                                self.dataController.previousWord()
                            }
                        }
                    }
                    ).disabled(self.currentIndex == 0)
                    Button("prev",action: {self.dataController.previousWord()}).disabled(self.currentIndex == 0)
                    Button("next", action: {self.dataController.nextWord()})
                    Button(">>", action: {
                        for _ in 1...20{
                            self.dataController.nextWord()
                        }
                    })

                }
            } else {
                Text("Initializing database")
            }
        }
        .onAppear{
            print(AVSpeechSynthesisVoice.speechVoices())

            // set up subscription to changes in index
            self.dataController.$currentWord.sink{[self] word in
                self.word = word
                self.currentIndex = self.dataController.currentWordIndex
            }
            .store(in: &self.subscriptions)
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
