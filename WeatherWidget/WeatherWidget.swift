//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by David Romero on 2024-12-13.
//

import WidgetKit
import SwiftUI
import Intents

// MARK: - Timeline Entry
struct WeatherEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let temperature: String
    let weatherIcon: String
    let hour: String
}

// MARK: - Weather Widget View
struct WeatherWidgetEntryView: View {
    var entry: WeatherEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            Color(red: 10.0 / 255.0, green: 14.0 / 255.0, blue: 69.0 / 255.0)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: spacing) {
                // Header with city name and time
                Text(entry.cityName)
                    .font(headerFont)
                    .foregroundColor(.white)
                Text(entry.hour)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    // Weather Icon
                    Image(systemName: entry.weatherIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                    
                    // Temperature
                    Text(entry.temperature)
                        .font(.headline)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
            }
            .padding(padding)
        }
    }
    
    // Dynamic sizes based on widget family
    private var imageSize: CGFloat {
        switch family {
        case .systemSmall:
            return 50
        case .systemMedium:
            return 75
        case .systemLarge:
            return 100
        @unknown default:
            return 50
        }
    }
    
    private var headerFont: Font {
        switch family {
        case .systemSmall:
            return .caption
        case .systemMedium:
            return .title3
        case .systemLarge:
            return .title2
        @unknown default:
            return .caption
        }
    }
    
    private var spacing: CGFloat {
        switch family {
        case .systemSmall:
            return 8
        case .systemMedium:
            return 10
        case .systemLarge:
            return 12
        @unknown default:
            return 8
        }
    }
    
    private var padding: EdgeInsets {
        switch family {
        case .systemSmall:
            return EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        case .systemMedium:
            return EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        case .systemLarge:
            return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        @unknown default:
            return EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        }
    }
}

// MARK: - Timeline Provider
struct WeatherProvider: AppIntentTimelineProvider {
    
    // Placeholder entry for widget previews
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), cityName: "Sample City", temperature: "20°C", weatherIcon: "sun.max.fill", hour: "2 PM")
    }

    // Provide a snapshot for the widget gallery
    func snapshot(for configuration: SelectCityIntent, in context: Context) async -> WeatherEntry {
        WeatherEntry(date: Date(), cityName: configuration.cityName, temperature: "20°C", weatherIcon: "sun.max.fill", hour: "2 PM")
    }

    // Provide a timeline for updates
    func timeline(for configuration: SelectCityIntent, in context: Context) async -> Timeline<WeatherEntry> {
        guard !configuration.cityName.isEmpty else {
            let entry = WeatherEntry(date: Date(), cityName: "No City", temperature: "N/A", weatherIcon: "questionmark", hour: "N/A")
            return Timeline(entries: [entry], policy: .never)
        }

        do {
            let weatherEntries = try await fetchWeather(for: configuration.cityName)
            return Timeline(entries: weatherEntries, policy: .atEnd)
        } catch {
            let entry = WeatherEntry(date: Date(), cityName: configuration.cityName, temperature: "Error", weatherIcon: "exclamationmark.triangle", hour: "N/A")
            return Timeline(entries: [entry], policy: .never)
        }
    }
    
    typealias Intent = SelectCityIntent
    
    typealias Entry = WeatherEntry


 

    func getSnapshot(for configuration: SelectCityIntent, in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let entry = WeatherEntry(date: Date(), cityName: configuration.cityName ?? "Sample City", temperature: "20°C", weatherIcon: "sun.max.fill", hour: "2 PM")
        completion(entry)
    }

    func getTimeline(for configuration: SelectCityIntent, in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let cityName = configuration.cityName
        guard !cityName.isEmpty else {
            let entry = WeatherEntry(date: Date(), cityName: "No City", temperature: "N/A", weatherIcon: "questionmark", hour: "N/A")
            completion(Timeline(entries: [entry], policy: .never)) // Use completion instead of return
            return
        }

        Task {
            do {
                let weatherEntries = try await fetchWeather(for: cityName)
                let timeline = Timeline(entries: weatherEntries, policy: .atEnd)
                completion(timeline)
            } catch {
                let entry = WeatherEntry(date: Date(), cityName: cityName, temperature: "Error", weatherIcon: "exclamationmark.triangle", hour: "N/A")
                completion(Timeline(entries: [entry], policy: .never))
            }
        }
    }


    private func fetchWeather(for cityName: String) async throws -> [WeatherEntry] {
        let viewModel = await WeatherViewModel()
        await viewModel.fetchWeatherForCity(cityName)

        guard let weatherData = await viewModel.weatherData?.hourly?.prefix(7) else { throw URLError(.badServerResponse) }

        let formatter = DateFormatter()
        formatter.dateFormat = "h a"

        return weatherData.map { hour in
            WeatherEntry(
                date: Date(timeIntervalSince1970: TimeInterval(hour.dt)),
                cityName: cityName,
                temperature: "\(Int(hour.temp))°C",
                weatherIcon: mapIconName(hour.weather.first?.icon ?? ""),
                hour: formatter.string(from: Date(timeIntervalSince1970: TimeInterval(hour.dt)))
            )
        }
    }

    private func mapIconName(_ icon: String) -> String {
        switch icon {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "09d", "10d": return "cloud.rain.fill"
        case "11d": return "cloud.bolt.fill"
        case "13d": return "snowflake"
        case "50d": return "cloud.fog.fill"
        default: return "questionmark"
        }
    }
}

// MARK: - Widget Main Entry

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCityIntent.self,
            provider: WeatherProvider()
        ) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Weather Widget")
        .description("Displays hourly weather for your selected city.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherWidgetEntryView(entry: WeatherEntry(
            date: Date(),
            cityName: "Sample City",
            temperature: "22°C",
            weatherIcon: "sun.max.fill",
            hour: "2 PM"
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
