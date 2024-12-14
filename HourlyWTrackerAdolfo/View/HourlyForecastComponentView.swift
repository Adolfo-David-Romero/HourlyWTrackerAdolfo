//
//  HourlyForecastComponentView.swift
//  HourlyWTrackerAdolfo
//
//  Created by David Romero on 2024-12-13.
//

import SwiftUI

struct HourlyForecastComponentView: View {
    let cityName: String
    let hourlyForecast: [HourlyForecast]
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("7-Hour Forecast for \(cityName)")
                .font(.headline)
                .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(hourlyForecast.prefix(7), id: \.dt) { forecast in
                        VStack(spacing: 10) {
                            Text(viewModel.formatTime(from: forecast.dt))
                                .font(.caption)
                            Image(systemName: viewModel.mapIconName(forecast.weather.first?.icon ?? ""))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            Text("\(Int(forecast.temp))°C")
                                .font(.headline)
                            Text("Wind: \(Int(forecast.windSpeed)) km/h")
                                .font(.caption2)
                            Text("Humidity: \(forecast.humidity)%")
                                .font(.caption2)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
    
    
}

#Preview {
    HourlyForecastComponentView(cityName: "Toronto", hourlyForecast: [], viewModel: WeatherViewModel())
}
