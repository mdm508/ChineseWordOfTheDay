//
//  TestcView.swift
//  ChineseWordOfTheDay
//
//  Created by YU HSIN HO on 6/10/23.
//

import SwiftUI
import SwiftData

let fd = {
    var  descriptior = FetchDescriptor<Word>()
    descriptior.fetchLimit = 1
    descriptior.sortBy = [SortDescriptor(\Word.traditional, order: .reverse)]
    return descriptior
}()

struct TodaysWordView: View {
    @Query(sort: \.frequency, order: .reverse)
    private var words: [Word]
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        Text(words[0].traditional).onAppear(){
                //fd goes her
        }
    }
}


struct TodaysWordView_Previews: PreviewProvider {
    static var previews: some View {
        TodaysWordView().modelContainer(Containers.previewContainer)
    }
}
