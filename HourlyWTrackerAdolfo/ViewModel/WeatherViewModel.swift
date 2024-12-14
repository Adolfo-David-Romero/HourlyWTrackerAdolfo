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
    @Published var weatherData: WeatherResponse? // Holds the weather data
    @Published var errorMessage: String? // Error messages for UI
    @Published var isLoading: Bool = false // Indicates loading state
    
    private let apiKey = "12013a6d197f9d54bc5a0e39861749a4"
    private let baseUrl = "https://api.openweathermap.org/data/3.0/onecall"
    
    // MARK: - Networking Logic
    
    /// Fetch weather data for a city
    func fetchWeatherForCity(_ cityName: String) async {
        guard !cityName.isEmpty else {
            errorMessage = "City name cannot be empty."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Step 1: Geocode the city name to get coordinates
            guard let (latitude, longitude) = try await geocodeCity(cityName: cityName) else {
                errorMessage = "Could not find location for \(cityName)."
                return
            }
            
            // Step 2: Fetch weather data using the coordinates
            try await fetchWeatherData(latitude: latitude, longitude: longitude)
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    /// Fetch weather data using latitude and longitude
    func fetchWeatherData(latitude: Double, longitude: Double, exclude: String = "minutely") async throws {
        // Construct the URL with parameters
        let urlStr = "\(baseUrl)?lat=\(latitude)&lon=\(longitude)&exclude=\(exclude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlStr) else {
            throw URLError(.badURL)
        }
        
        do {
            // Step 1: Perform the API request
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Step 2: Check the HTTP response
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                throw URLError(.badServerResponse, userInfo: ["StatusCode": statusCode])
            }
            
            // Step 3: Decode the JSON response
            let decodedWeather = try JSONDecoder().decode(WeatherResponse.self, from: data)
            weatherData = decodedWeather
            errorMessage = nil
        } catch {
            throw error // Propagate the error for handling at the call site
        }
    }
    
    // MARK: - Geocoding Logic
    
    /// Geocode a city name to obtain latitude and longitude
    func geocodeCity(cityName: String) async throws -> (Double, Double)? {
        let geocoder = CLGeocoder()
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(cityName) { placemarks, error in
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
}
