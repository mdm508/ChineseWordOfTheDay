//
//  SampleWords.swift
//  ChineseWordOfTheDay
//
//  Created by YU HSIN HO on 6/10/23.
//

import Foundation


func loadWordsFromJson() -> [Word] {
    if let url = Bundle.main.url(forResource: "output", withExtension: "json") {
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let words = try decoder.decode([Word].self, from: jsonData)
            return words
            
        } catch let error as DecodingError {
                // Handle decoding errors
            print("Decoding error: \(error)")
        } catch let error {
                // Handle other errors
            print("Error: \(error)")
        }
    } else {
        print("JSON file not found.")
    }
    return []
    
}




struct SampleWords{
    static var contents = loadWordsFromJson()
}
