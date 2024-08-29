//
//  weatherAPI.swift
//  weatherapp
//
//  Created by Kedan Zha on 8/28/24.
//

import Foundation

//using Open-Meteo api to retrieve current and future forcasts
func fetchWeatherAndForecast(for latitude: Double, longitude: Double, completion: @escaping (WeatherResponse?) -> Void) {
    let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=temperature_2m_max,temperature_2m_min,weathercode&hourly=temperature_2m,weathercode&current_weather=true&timezone=auto"
    guard let url = URL(string: urlString) else { return }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching data: \(String(describing: error))")
            completion(nil)
            return
        }
        
        do {
            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
            print("Weather Response: \(weatherResponse)")
            completion(weatherResponse)
        } catch {
            print("Error decoding data: \(error)")
            completion(nil)
        }
    }.resume()
}

//supporting struct for PositionStack API
struct PositionStackResponse: Codable {
    let data: [PositionStackData]
}

struct PositionStackData: Codable {
    let latitude: Double
    let longitude: Double
}
