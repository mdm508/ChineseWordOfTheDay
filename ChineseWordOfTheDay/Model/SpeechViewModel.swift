//
//  File.swift
//  ChineseWordOfTheDay
//
//  Created by wonderland on 5/2/23.
//

import Foundation
import AVFoundation
import Combine

typealias LanguageCode = SpeechViewModel.LanguageCode

class SpeechViewModel: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var subs = Set<AnyCancellable>()
    @Published var isSpeaking = false
    override init(){
        super.init()
        self.synthesizer.delegate = self
    }
}
extension SpeechViewModel {
    func speak(_ text: String, _ languageCode: LanguageCode){
        guard let voice = AVSpeechSynthesisVoice(language: languageCode.rawValue) else {
            print("Invalid language code: \(languageCode.rawValue)")
            return
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        self.synthesizer.speak(utterance)
    }
}
extension SpeechViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.isSpeaking = true
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.isSpeaking = false
    }
}
extension SpeechViewModel {
    enum LanguageCode: String {
        case english = "en-US"
        case chineseTaiwan = "zh-TW"
    }

}
