//
//  ContentView.swift
//  ChineseWordOfTheDay
//
//  Created by m on 11/26/22.
//

import SwiftUI

struct HomeView {
    @StateObject var support: DictionarySupport = DictionarySupport()
    var currentWord: Word {
        return support.currentWord
    }
}
extension HomeView: View {
    var body: some View {
        VStack(){
            Group{
                WordView(self.currentWord.traditional)
                Text(self.currentWord.pinyin)
                Text(self.currentWord.english)
            }
            Spacer()
            Text(self.support.wordIndex())
            HStack{
                Button("prev",action: self.support.prevWord)
                Button("next", action: self.support.nextWord)
            }
   
        }.padding()
            .onAppear{
                let refreshManager = RefreshManager.shared
                refreshManager.loadDataIfNeeded() { success in
                    if success {
                        self.support.nextWord()
                    }
                }
            }
    }

}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
