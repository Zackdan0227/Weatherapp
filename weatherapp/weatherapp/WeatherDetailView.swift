import SwiftUI
import CoreLocation

struct WeatherDetailView: View {
    @Binding var city: String?
    @State private var weatherResponse: WeatherResponse?
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var timeZoneManager = TimeZoneManager()
    @State private var isLoading = true
    @State private var cityTimeZone: TimeZone = .current
    @State private var selectedHourIndex: Int?
    @State private var isCelsius: Bool = true // Track whether to display Celsius or Fahrenheit
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Fetching weather...")
                    .padding()
            } else if let weatherResponse = weatherResponse {
                
                Text(city ?? "Current Location")
                    .font(.largeTitle)
                    .padding(.top)
                
                Text("Local Time: \(formatCurrentTime())")
                    .font(.subheadline)
                    .padding(.bottom)
                
                VStack(spacing: 10) {
                    Text(selectedHourIndex == nil ? "Current Temperature" : "Temperature at \(formatHour(weatherResponse.hourly.time[selectedHourIndex ?? 0]))")
                        .font(.headline)
                    HStack(spacing: 20) {
                        let hour = getHour(from: weatherResponse.hourly.time[selectedHourIndex ?? 0])
                        let isDaytime = hour >= 6 && hour < 18
                        Image(systemName: weatherIcon(for: selectedWeatherCode, isDaytime: isDaytime))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        Text("\(selectedTemperature, specifier: "%.1f")°\(isCelsius ? "C" : "F")")
                            .font(.system(size: 50, weight: .bold))
                    }
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(filteredHourlyIndices, id: \.self) { index in
                            let hour = getHour(from: weatherResponse.hourly.time[index])
                            let isDaytime = hour >= 6 && hour < 18
                            
                            Button(action: {
                                self.selectedHourIndex = index
                            }) {
                                VStack(spacing: 10) {
                                    Text(formatHour(weatherResponse.hourly.time[index]))
                                        .font(.caption)
                                    Image(systemName: weatherIcon(for: weatherResponse.hourly.weathercode[index], isDaytime: isDaytime))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                    Text("\(convertedTemperature(weatherResponse.hourly.temperature_2m[index]), specifier: "%.1f")°\(isCelsius ? "C" : "F")")
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedHourIndex == index ? Color.blue : Color.clear, lineWidth: 3)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                VStack(spacing: 10) {
                    Text("5-Day Forecast")
                        .font(.headline)
                    ForEach(0..<5, id: \.self) { index in
                        HStack {
                            Text(formatDay(weatherResponse.daily.time[index]))
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                            Image(systemName: weatherIcon(for: weatherResponse.daily.weathercode[index], isDaytime: true))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                            Text("\(convertedMaxTemperature(index), specifier: "%.1f")°\(isCelsius ? "C" : "F")")
                                .font(.system(size: 16))
                            Text("/")
                                .foregroundColor(.gray)
                            Text("\(convertedMinTemperature(index), specifier: "%.1f")°\(isCelsius ? "C" : "F")")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                Button(action: {
                    isCelsius.toggle()
                }) {
                    Text(isCelsius ? "Switch to °F" : "Switch to °C")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            } else {
                Text("Unable to fetch weather data.")
                    .font(.headline)
                    .padding()
            }
           
            Spacer()
        }
        .navigationTitle("Weather Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchWeather()
        }
    }
    
    // Computed properties to return selected weather details
    var selectedTemperature: Double {
        if let index = selectedHourIndex {
            return convertedTemperature(weatherResponse?.hourly.temperature_2m[index] ?? 0.0)
        }
        return convertedTemperature(weatherResponse?.current_weather.temperature ?? 0.0)
    }
    
    var selectedWeatherCode: Int {
        if let index = selectedHourIndex {
            return weatherResponse?.hourly.weathercode[index] ?? weatherResponse?.current_weather.weathercode ?? 0
        }
        return weatherResponse?.current_weather.weathercode ?? 0
    }
    
    // Convert temperature based on the selected unit
    private func convertedTemperature(_ temperature: Double) -> Double {
        return isCelsius ? temperature : (temperature * 9/5) + 32
    }
    
    // Convert max temperature for the 5-day forecast
    private func convertedMaxTemperature(_ index: Int) -> Double {
        let temperature = weatherResponse?.daily.temperature_2m_max[index] ?? 0.0
        return isCelsius ? temperature : (temperature * 9/5) + 32
    }
    
    // Convert min temperature for the 5-day forecast
    private func convertedMinTemperature(_ index: Int) -> Double {
        let temperature = weatherResponse?.daily.temperature_2m_min[index] ?? 0.0
        return isCelsius ? temperature : (temperature * 9/5) + 32
    }
    
    
    private var filteredHourlyIndices: [Int] {
        guard let hourlyTimes = weatherResponse?.hourly.time else { return [] }
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm" // Ensure this matches your input format exactly.
        dateFormatter.timeZone = cityTimeZone // Set to city's time zone
        
        // Format the current date/time to the city's time zone and parse it back to a Date
        if let localNow = dateFormatter.date(from: dateFormatter.string(from: now)) {
            var calendar = Calendar.current
            calendar.timeZone = cityTimeZone
            
            return hourlyTimes.indices.filter { index in
                if let date = customDateFormatter().date(from: hourlyTimes[index]) {
                    return date >= localNow && calendar.isDateInToday(date)
                }
                return false
            }
        }
        
        return [] // Return an empty array if conversion fails
    }
    
    //helper funciton
    func fetchWeather() {
        if let city = self.city {
            //a empty city names means we should locate the user
            if city != ""{
                geocodeCityName(cityName: city) { location in
                    if location?.coordinate.latitude != 0.0 && location?.coordinate.longitude != 0.0 {
                        fetchWeatherData(for: location ?? CLLocation(latitude: 0, longitude: 0))
                        reverseGeocodeLocation(location: location ?? CLLocation(latitude: 0, longitude: 0))
                        
                    } else {
                        isLoading = false
                    }
                }
            }else{
                print("locate me")
                if let location = locationManager.location {
                    fetchWeatherData(for: location)
                }
                //convert lat and long to city name
                reverseGeocodeLocation(location: locationManager.location ?? CLLocation(latitude: 0, longitude: 0))
            }
        } else {
            isLoading = false
            
        }
    }
    
    
    
    func fetchWeatherData(for location: CLLocation) {
        print("Fetching weather for \(location.coordinate.latitude), \(location.coordinate.longitude)")
        isLoading = true
        fetchWeatherAndForecast(for: location.coordinate.latitude, longitude: location.coordinate.longitude) { fetchedWeather in
            DispatchQueue.main.async {
                self.weatherResponse = fetchedWeather
                self.timeZoneManager.fetchTimeZone(for: location) { timeZone in
                    DispatchQueue.main.async {
                        self.cityTimeZone = timeZone ?? .current
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
}

// MARK: - Extensions
//This extension contains the geocoding and reverse geocoding methods
extension WeatherDetailView {
    //corrects city name from user's input
    func geocodeCityName(cityName: String, completion: @escaping (CLLocation?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            completion(placemarks?.first?.location)
        }
    }
    //reverses geocode location to get city name
    func reverseGeocodeLocation(location: CLLocation) {
        if location == CLLocation(latitude: 0, longitude: 0) {
            print("Invalid location")
            self.isLoading = false
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("Reverse geocoding failed: \(error!.localizedDescription)")
                self.isLoading = false
                return
            }
            //update city time zone
            self.cityTimeZone = placemark.timeZone ?? .current
            if let city = placemark.locality {
                self.city = city // Update the city name based on the coordinates
                fetchWeatherData(for: location)
            } else {
                print("City name could not be found")
                self.isLoading = false
            }
        }
    }
}

extension WeatherDetailView {
    //neat Apple's SF Symbols for weather icons
    //param: code - weather code, isDaytime - if it's daytime
    func weatherIcon(for code: Int, isDaytime: Bool) -> String {
        switch code {
        case 0:
            return isDaytime ? "sun.max.fill" : "moon.stars.fill"
        case 1, 2, 3:
            return isDaytime ? "cloud.sun.fill" : "cloud.moon.fill"
        case 45, 48:
            return "cloud.fog.fill"
        case 51, 53, 55:
            return "cloud.drizzle.fill"
        case 61, 63, 65:
            return "cloud.rain.fill"
        case 71, 73, 75:
            return "cloud.snow.fill"
        case 80, 81, 82:
            return "cloud.heavyrain.fill"
        case 95, 96, 99:
            return "cloud.bolt.rain.fill"
        default:
            return "cloud.fill"
        }
    }
}

//formatting time methods
extension WeatherDetailView{
    func formatDay(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        formatter.timeZone = cityTimeZone // Parse as UTC
        if let date = formatter.date(from: isoDate) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE" // e.g., Monday
            dayFormatter.timeZone = cityTimeZone
            return dayFormatter.string(from: date)
        }
        return ""
    }
    
    func formatCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = cityTimeZone
        dateFormatter.dateFormat = "EEE, MMM d, h:mm a" // e.g., Mon, Aug 29, 3:45 PM
        return dateFormatter.string(from: Date())
    }
    
    func getHour(from isoDate: String) -> Int {
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.timeZone = cityTimeZone
        
        if let date = isoFormatter.date(from: isoDate) {
            var calendar = Calendar.current
            calendar.timeZone = cityTimeZone
            return calendar.component(.hour, from: date)
        }
        
        return 0 // Default to 0 if parsing fails
    }
    
    func formatHour(_ isoDate: String) -> String {
        // Create a formatter for ISO 8601
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.timeZone = cityTimeZone
        
        // Check if the date can be parsed
        if let date = isoFormatter.date(from: isoDate) {
            // Create a formatter for the desired output
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "h:mm a" // Example: "9:00 AM"
            outputFormatter.timeZone = cityTimeZone
            return outputFormatter.string(from: date)
        } else {
            print("Failed to parse date: \(isoDate)")
            return "Invalid date"
        }
    }
    func customDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = cityTimeZone
        return formatter
    }
}
