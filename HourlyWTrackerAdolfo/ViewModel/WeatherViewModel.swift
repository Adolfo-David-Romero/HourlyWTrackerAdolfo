//
//  WeatherViewModel.swift
//  HourlyWTrackerAdolfo
//
//  Created by David Romero on 2024-12-13.
//

import Foundation
import SwiftUI
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherResponse?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var cityName: String = ""

    private let apiKey = "12013a6d197f9d54bc5a0e39861749a4"
    private let baseUrl = "https://api.openweathermap.org/data/3.0/onecall"

    // MARK: - Networking
    /// Fetch weather data for a city
    func fetchWeatherForCity(_ city: String) async {
        guard !city.isEmpty else {
            errorMessage = "City name cannot be empty."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // Geocode the city
            guard let (latitude, longitude) = try await geocodeCity(city: city) else {
                errorMessage = "Could not find location for \(city)."
                return
            }

            cityName = city // Save city name
            // Fetch weather data using coordinates
            try await fetchWeatherData(lat: latitude, lon: longitude)
        } catch {
            errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }
    }

    /// Fetch weather data using latitude and longitude
    func fetchWeatherData(lat: Double, lon: Double) async throws {
        let urlStr = "\(baseUrl)?lat=\(lat)&lon=\(lon)&exclude=minutely,daily&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decodedWeather = try JSONDecoder().decode(WeatherResponse.self, from: data)
        weatherData = decodedWeather
        errorMessage = nil
    }

    // MARK: - Geocoding
    /// Geocode a city name to get latitude and longitude
    func geocodeCity(city: String) async throws -> (Double, Double)? {
        let geocoder = CLGeocoder()
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(city) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let location = placemarks?.first?.location {
                    continuation.resume(returning: (location.coordinate.latitude, location.coordinate.longitude))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    //MARK: - UI Formatting
    func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
    
    //https://openweathermap.org/weather-conditions
    func mapIconName(_ icon: String) -> String {
        switch icon {
        case "01d": return "sun.max.fill"
        case "02d": return "cloud.sun.fill"
        default: return "cloud.fill"
        }
    }
}
