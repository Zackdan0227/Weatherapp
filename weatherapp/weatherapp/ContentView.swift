import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var showWeather = false
    @StateObject private var locationManager = LocationManager.shared
    @State private var searchCity: String?
    @State private var showInfo = false

    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                TextField("Search for a city...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 30)

                // Search and Locate Me Buttons
                HStack {
                    Button(action: {
                        searchCity = searchText
                        showWeather = true
                    }) {
                        Text("Search")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(searchText.isEmpty)

                    Button(action: {
                        searchCity = ""
                        showWeather = true
                    }) {
                        Text("Locate Me")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
                .padding()

                Spacer()
                
                Button(action:{
                    showInfo = true
                }){
                    Text("About PMA")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Kedan Zha's Weather App 🌦️")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showWeather) {
                WeatherDetailView(city: $searchCity)
            }
            .navigationDestination(isPresented: $showInfo) {
                PMAInfoVIew()
            }
        }
    }
}
