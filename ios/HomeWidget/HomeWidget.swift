//
//  HomeWidget.swift
//  HomeWidget
//
//  Created by ghayadah on 11/03/2025.
//

import WidgetKit
import SwiftUI
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "No tasks", animalImage: "default_animal")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.homewidget")
        let title = userDefaults?.string(forKey: "headline_title") ?? "No tasks"
        let animalImage = userDefaults?.string(forKey: "animal_currently") ?? "default_animal"

        let entry = SimpleEntry(date: Date(), title: title, animalImage: animalImage)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.homewidget")
        let title = userDefaults?.string(forKey: "headline_title") ?? "No tasks"
        let animalImage = userDefaults?.string(forKey: "animal_currently") ?? "default_animal"

        let entry = SimpleEntry(date: Date(), title: title, animalImage: animalImage)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}






struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let animalImage: String
}
struct HomeWidgetEntryView: View {
    var entry: Provider.Entry


    let backgroundColor = Color(red: 0.1568, green: 0.1568, blue: 0.1568) 
    let textColor = Color(red: 0.9725, green: 0.8549, blue: 0.2509)

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.05) {
               


                Text(entry.title)
                    .font(.system(size: geometry.size.width * 0.10, weight: .regular))
                    .foregroundColor(textColor) 
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 0)
                

                if let uiImage = UIImage(named: entry.animalImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                        .clipShape(Circle())
                } else {
                    Text("")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor) 
            .edgesIgnoringSafeArea(.all)
        }
    }
}
struct HomeWidget: Widget {
    let kind: String = "HomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                HomeWidgetEntryView(entry: entry)
                    .containerBackground(Color(red: 0.1568, green: 0.1568, blue: 0.1568), for: .widget)
            } else {
                HomeWidgetEntryView(entry: entry)
                    .padding(0)
                    .background(Color(red: 0.1568, green: 0.1568, blue: 0.1568))
            }
        }
        .configurationDisplayName("My Widget")
        .description("Displays your next task.")
    }
}


