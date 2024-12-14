//
//  WeatherModel.swift
//  HourlyWTrackerAdolfo
//
//  Created by David Romero on 2024-12-13.
//

import Foundation

// MARK: - WeatherResponse

struct WeatherResponse: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezoneOffset: Int
    let current: CurrentWeather
    let hourly: [HourlyForecast]?
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone
        case timezoneOffset = "timezone_offset"
        case current, hourly
    }
}

// MARK: - Current Weather
struct CurrentWeather: Codable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
}

// MARK: - Hourly Forecast
struct HourlyForecast: Codable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
    let windSpeed: Double
    let humidity: Int

    enum CodingKeys: String, CodingKey {
        case dt, temp, weather
        case windSpeed = "wind_speed"
        case humidity
    }
}

// MARK: - Weather
struct Weather: Codable {
    let description: String
    let icon: String
}

