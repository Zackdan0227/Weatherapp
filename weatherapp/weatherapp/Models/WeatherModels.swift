//
//  WeatherModels.swift
//  weatherapp
//
//  Created by Kedan Zha on 8/28/24.
//

import Foundation

struct WeatherResponse: Codable {
    let current_weather: CurrentWeather
    let daily: DailyForecast
}

struct CurrentWeather: Codable {
    let temperature: Double
    let windspeed: Double
    let weathercode: Int
}

struct DailyForecast: Codable {
    let time: [String]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
    let weathercode: [Int]
}

