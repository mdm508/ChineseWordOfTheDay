//
//  Word.swift
//  words
//
//  Created by YU HSIN HO on 6/10/23.
//

import Foundation
import SwiftData

@Model
final class Word {
    let index: Int
    let traditional: String
    let zhuyin: String
    let simplified: String
    let pinyin: String
    let level: Double
    let meanings: [String]
    let context: String
    let writtenFrequency: Int
    let spokenFrequency: Int
    let frequency: Int
    
    init(index: Int, traditional: String, zhuyin: String, simplified: String, pinyin: String, level: Double, meanings: [String], context: String, writtenFrequency: Int, spokenFrequency: Int, frequency: Int) {
        self.index = index
        self.traditional = traditional
        self.zhuyin = zhuyin
        self.simplified = simplified
        self.pinyin = pinyin
        self.level = level
        self.meanings = meanings
        self.context = context
        self.writtenFrequency = writtenFrequency
        self.spokenFrequency = spokenFrequency
        self.frequency = frequency
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let index = try container.decode(Int.self, forKey: .index)
        let traditional = try container.decode(String.self, forKey: .traditional)
        let zhuyin = try container.decode(String.self, forKey: .zhuyin)
        let simplified = try container.decode(String.self, forKey: .simplified)
        let pinyin = try container.decode(String.self, forKey: .pinyin)
        let level = try container.decode(Double.self, forKey: .level)
        let meanings = try container.decode([String].self, forKey: .meanings)
        let context = try container.decode(String.self, forKey: .context)
        let writtenFrequency = try container.decode(Int.self, forKey: .writtenFrequency)
        let spokenFrequency = try container.decode(Int.self, forKey: .spokenFrequency)
        let frequency = try container.decode(Int.self, forKey: .frequency)
        
        self.init(index: index, traditional: traditional, zhuyin: zhuyin, simplified: simplified, pinyin: pinyin, level: level, meanings: meanings, context: context, writtenFrequency: writtenFrequency, spokenFrequency: spokenFrequency, frequency: frequency)
    }
}
extension Word: Decodable {
    enum CodingKeys: String, CodingKey {
        case index
        case traditional
        case zhuyin
        case simplified
        case pinyin
        case level
        case meanings
        case context
        case writtenFrequency
        case spokenFrequency
        case frequency
    }
    
   
}
