//
//  LocationManager.swift
//  HourlyWTrackerAdolfo
//
//  Created by David Romero on 2024-12-13.
//

import Foundation
import CoreLocation


@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherResponse? // Use WeatherResponse as the model
    @Published var currentLink: URL?
    @Published var errorMessage: String?
    
    // API/URL Info
    private let apiKey = "12013a6d197f9d54bc5a0e39861749a4"
    private let baseUrl = "https://api.openweathermap.org/data/3.0/onecall"
    
    /// Fetch weather data using latitude and longitude
    func fetchWeatherData(latitude: Double, longitude: Double, exclude: String = "minutely") async {
        // Construct the URL string with query parameters
        let urlStr = "\(baseUrl)?lat=\(latitude)&lon=\(longitude)&exclude=\(exclude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlStr) else {
            errorMessage = "Invalid URL"
            return
        }
        currentLink = url
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Invalid response: Status Code \((response as? HTTPURLResponse)?.statusCode ?? -1)"
                return
            }
            
            // Decode the data into the WeatherResponse model
            let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
            self.weatherData = weather
            errorMessage = nil
        } catch {
            errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }
    }
}
