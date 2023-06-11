//
//  TestcView.swift
//  ChineseWordOfTheDay
//
//  Created by YU HSIN HO on 6/10/23.
//

import SwiftUI
import SwiftData
struct TestcView: View {
    @Query(sort) private var words: [Word]
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        Text(words[0].traditional)
    }
}

#Preview {
    TestcView()
}
