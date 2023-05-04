//
//  PlayButton.swift
//  ChineseWordOfTheDay
//
//  Created by wonderland on 5/4/23.
//

import SwiftUI

struct PlayButton {
    @StateObject var speechViewModel: SpeechViewModel = SpeechViewModel()
    var textToSpeak: String
    var lang: LanguageCode

}
extension PlayButton: View {
    var body: some View {
        Button(){
            self.speechViewModel.speak(self.textToSpeak, self.lang)
            
        } label: {
            Image(systemName: "play.fill")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
        }.disabled(speechViewModel.isSpeaking)
            .foregroundColor(self.speechViewModel.isSpeaking ? Color.gray : Color.blue)
            .opacity(self.speechViewModel.isSpeaking ? 0.5 : 1)
    }
}

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
//        PlayButton(textToSpeak: Binding.constant("hello world."),
//                   lang: Binding.constant(SpeechViewModel.LanguageCode.english))
        PlayButton(textToSpeak: "hi", lang: LanguageCode.english)
    }
}
