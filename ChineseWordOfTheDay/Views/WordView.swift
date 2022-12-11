//
//  ChineseCharacter.swift
//  ChineseWordOfTheDay
//
//  Created by m on 12/9/22.
//

import SwiftUI

struct WordView {
    var word: String
    init(_ word:String){
        self.word = word
    }
}

extension WordView: View {
    var body: some View {
        Text(self.word).font(Font.custom("kaiu", size: 50))
    }
}

struct ChineseCharacter_Previews: PreviewProvider {
    static var previews: some View {
        WordView("精")
    }
}
