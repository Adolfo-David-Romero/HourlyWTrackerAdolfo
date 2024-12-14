//
//  ContentView.swift
//  HourlyWTrackerAdolfo
//
//  Created by David Romero on 2024-11-22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()

    var body: some View {
        NavigationView {
            VStack {
                CitySearchComponentView(viewModel: weatherViewModel)

                if let weather = weatherViewModel.weatherData, let hourly = weather.hourly {
                    HourlyForecastComponentView(cityName: weatherViewModel.cityName, hourlyForecast: hourly, viewModel: weatherViewModel)
                } else {
                    Text("Enter a city to get started.")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("HourlyWTrackerAdolfo")
        }
    }
}

#Preview {
    ContentView()
}
