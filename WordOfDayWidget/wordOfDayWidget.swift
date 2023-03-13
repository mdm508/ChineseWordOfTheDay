//
//  wordOfDayWidget.swift
//  wordOfDayWidget
//
//  Created by m on 12/2/22.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider{
    typealias Entry = WidgetContent
    let dataController = DataController()
    func placeholder(in context: Context) -> WidgetContent {
        WidgetContent(date: Date(), currentWord: "企鵝", pinyin: "Qi4e2")
    }
    @AppStorage("wordIndex", store: UserDefaults(suiteName: "group.matthedm.wod.chinese")) var currentWordIndex: Int = 0
    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> ()) {
        let dataController = DataController()
        let word = dataController.getWord()
        let widgetContent = WidgetContent(date: Date(), currentWord: word.traditional ?? "",
                                          pinyin: word.pinyin ?? "")
        completion(widgetContent)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let word = dataController.getWord()
        let widgetContent = WidgetContent(date: Date(), currentWord: word.traditional ?? "",
                                          pinyin: word.pinyin ?? "")
        let timeline = Timeline(entries: [widgetContent], policy: .atEnd)
        completion(timeline)
    }
}

struct WidgetContent: TimelineEntry {
    let date: Date
    let currentWord: String
    let pinyin: String
}

struct wordOfDayWidgetEntryView : View {
    var entry: Provider.Entry


    var body: some View {
        VStack{
            WordView(entry.currentWord)
            Text(entry.pinyin)
        }
    }
}

@main
struct wordOfDayWidget: Widget {
    let kind: String = "wordOfDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            wordOfDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Chinese Word of the Day Widget")
        .description("Display the current chinese word of the day")
        .supportedFamilies([.systemSmall])
    }
}

//var body: some WidgetConfiguration {
//      StaticConfiguration(
//          kind: "com.mygame.game-status",
//          provider: GameStatusProvider(),
//      ) { entry in
//          GameStatusView(entry.gameStatus)
//      }
//      .configurationDisplayName("Game Status")
//      .description("Shows an overview of your game status")
//      .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
//  }
//}

struct wordOfDayWidget_Previews: PreviewProvider {
    static var previews: some View {
        wordOfDayWidgetEntryView(entry: WidgetContent(date: Date(),currentWord: "企鵝", pinyin: "Qi4e2"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
