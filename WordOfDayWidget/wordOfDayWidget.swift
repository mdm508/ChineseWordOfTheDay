//
//  wordOfDayWidget.swift
//  wordOfDayWidget
//
//  Created by m on 12/2/22.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [SimpleEntry] = [SimpleEntry(date: Date(), configuration: configuration)]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let support: DictionarySupport = DictionarySupport()
}

struct wordOfDayWidgetEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        VStack{
            WordView(self.entry.support.currentWord.traditional)
            Text(self.entry.support.currentWord.pinyin)
        }
    }
}

@main
struct wordOfDayWidget: Widget {
    let kind: String = "wordOfDayWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            wordOfDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Chinese Word of the Day Widget")
        .description("Display the current chinese word of the day")
        .supportedFamilies([.systemSmall])
    }
}

struct wordOfDayWidget_Previews: PreviewProvider {
    static var previews: some View {
        wordOfDayWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
