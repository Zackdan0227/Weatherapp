//
//  ContentView.swift
//  weatherapp
//
//  Created by Kedan Zha on 8/28/24.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherResponse: WeatherResponse?
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 20) {
            if let weatherResponse = weatherResponse {
                // Current Weather
                VStack(spacing: 10) {
                    Text("Current Temperature")
                        .font(.headline)
                    HStack {
                        Image(svgName(for: weatherResponse.current_weather.weathercode))
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("\(weatherResponse.current_weather.temperature, specifier: "%.1f")°C")
                            .font(.largeTitle)
                    }
                }
                
                // 5-Day Forecast
                VStack(spacing: 10) {
                    Text("5-Day Forecast")
                        .font(.headline)
                    ForEach(0..<weatherResponse.daily.time.count, id: \.self) { index in
                        HStack {
                            Text(weatherResponse.daily.time[index])
                            Spacer()
                            Image(svgName(for: weatherResponse.daily.weathercode[index]))
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("\(weatherResponse.daily.temperature_2m_max[index], specifier: "%.1f")°C / \(weatherResponse.daily.temperature_2m_min[index], specifier: "%.1f")°C")
                        }
                        .padding(.horizontal)
                    }
                }
            } else if isLoading {
                Text("Fetching weather...")
            } else {
                Text("Unable to fetch weather data.")
            }
        }
        .padding()
        .onAppear {
            if let location = locationManager.location {
                fetchWeatherData(for: location)
            }
        }
        .onChange(of: locationManager.location) { newLocation in
            if let newLocation = newLocation {
                fetchWeatherData(for: newLocation)
            }
        }
    }
    
    private func fetchWeatherData(for location: CLLocation) {
        isLoading = true
        fetchWeatherAndForecast(for: location.coordinate.latitude, longitude: location.coordinate.longitude) { fetchedWeather in
            DispatchQueue.main.async {
                self.weatherResponse = fetchedWeather
                self.isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
