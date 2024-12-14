//
//  SelectCityIntent.swift
//  WeatherWidgetExtension
//
//  Created by David Romero on 2024-12-13.
//

import Foundation
import AppIntents

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
struct SelectCityIntent: AppIntent, WidgetConfigurationIntent {
    // Title and Description
    static var title: LocalizedStringResource = "Select City"
    static var description = IntentDescription("Choose a city for weather updates in the widget.")

    // City Name Parameter
    @Parameter(title: "City Name", default: "Toronto")
    var cityName: String

    // Parameter Summary
    static var parameterSummary: some ParameterSummary {
        Summary("Display weather for \(\.$cityName)")
    }

    // Prediction Configuration
    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\SelectCityIntent.$cityName)) { cityName in
            DisplayRepresentation(
                title: "\(cityName)",
                subtitle: "Weather updates for \(cityName)"
            )
        }
    }

    // Perform Method (Placeholder)
    func perform() async throws -> some IntentResult {
        // This is not required for widget configuration but can remain as a placeholder.
        return .result()
    }
}
