//
//  Word.swift
//  ChineseWordOfTheDayTests
//
//  Created by m on 11/27/22.
//

import Foundation

struct Word: Codable {
    let traditional: String
    let simplified: String
    let pinyin: String
    let english: String
}
