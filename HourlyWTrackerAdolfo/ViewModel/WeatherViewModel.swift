//
//  WeatherViewModel.swift
//  HourlyWTrackerAdolfo
//
//  Created by David Romero on 2024-12-13.
//

import Foundation
import SwiftUI
import CoreLocation

class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherResponse?
    @Published var currentLink: URL?
    @Published var errorMessage: String?
    
    // API/URL Info
    let apiKey = "12013a6d197f9d54bc5a0e39861749a4"
    let baseUrl = "https://api.openweathermap.org/data/3.0/onecall"
    
    /// Fetch weather data using latitude and longitude
    func fetchWeatherData(latitude: Double, longitude: Double, exclude: String = "minutely") {
        // Construct the URL string with query parameters
        let urlStr = "\(baseUrl)?lat=\(latitude)&lon=\(longitude)&exclude=\(exclude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlStr) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }
        currentLink = url
        
        // Make the API request
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            // Check if the response is a valid HTTP response
            if let response = response as? HTTPURLResponse {
                print("Status Code: \(response.statusCode)")
                if response.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid response: Status Code \(response.statusCode)"
                    }
                    return
                }
            }
            
            // Ensure data exists
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from server."
                }
                return
            }
            
            // Debugging: Print raw JSON response
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            
            // Decode the data into the WeatherResponse model
            do {
                let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.weatherData = weather
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
