//
//  CitySearchComponentView.swift
//  HourlyWTrackerAdolfo
//
//  Created by David Romero on 2024-12-13.
//

import SwiftUI
import Foundation
struct CitySearchComponentView: View {
    @State var cityName: String = "" // User input for city name
    @ObservedObject var weatherViewModel = WeatherViewModel () // Observed ViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Search Weather by City")
                .font(.headline)
                .padding()
            
            // TextField for user input
            TextField("Enter city name", text: $cityName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.words)
                .disableAutocorrection(true)
            
            // Search Button
            Button(action: {
                Task {
                    try await weatherViewModel.fetchWeatherForCity(cityName)
                }
            }) {
                Text("Search")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .disabled(weatherViewModel.isLoading) // Disable button while loading
            
            // Loading indicator
            if weatherViewModel.isLoading {
                ProgressView()
                    .padding()
            }
            
            // Error message
            if let errorMessage = weatherViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            // Display weather data if available
            if let weather = weatherViewModel.weatherData {
                VStack(spacing: 10) {
                    Text("Temperature: \(weather.current.temp)°C")
                    Text("Condition: \(weather.current.weather.first?.description ?? "N/A")")
                }
                .padding()
            }
        }
        .padding()
    }
}

#Preview {
    CitySearchComponentView(weatherViewModel: WeatherViewModel())
}
