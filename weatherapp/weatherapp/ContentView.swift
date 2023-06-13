//
//  ContentView.swift
//  weatherapp
//
//  Created by Mazin on 13/06/23.
//
import SwiftUI

struct ContentView: View {
    @State private var city: String = ""
    @State private var weatherData: WeatherData? = nil
    @State private var isLoading: Bool = false
    
    private let lastSearchedCityKey = "LastSearchedCity"

    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
            VStack {
                Text("Weather App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                TextField("Enter city name", text: $city)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(.black)
                
                Button(action: {
                    fetchWeatherData(for: city)
                }) {
                    Text("Search")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .padding()
                }
                
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let weatherData = weatherData {
                    WeatherView(weatherData: weatherData)
                } else {
                    Text("No weather data available")
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
        }
        .onAppear {
            loadLastSearchedCity()
        }
    }
    
    func fetchWeatherData(for city: String) {
        isLoading = true
        
        let apiKey = "f31a0683a9f2237c2328de277b09123d" // Replace with your OpenWeatherMap API key
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)" // Construct the API URL with the city and API key
        guard let url = URL(string: urlString) else {
            // Handle invalid URL error
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // Handle network error
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
                    let weatherData = WeatherData(
                        temperature: "\(decodedResponse.main.temp)",
                        humidity: "\(decodedResponse.main.humidity)",
                        windSpeed: "\(decodedResponse.wind.speed)",
                        description: decodedResponse.weather.first?.description ?? ""
                    )
                    
                    DispatchQueue.main.async {
                        isLoading = false
                        self.weatherData = weatherData
                        saveLastSearchedCity(city)
                    }
                } catch {
                    // Handle JSON decoding error
                    print("JSON decoding error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
            }
        }.resume()
    }
    
    func saveLastSearchedCity(_ city: String) {
        UserDefaults.standard.set(city, forKey: lastSearchedCityKey)
    }
    
    func loadLastSearchedCity() {
        if let lastSearchedCity = UserDefaults.standard.string(forKey: lastSearchedCityKey) {
            city = lastSearchedCity
            fetchWeatherData(for: lastSearchedCity)
        }
    }
}

struct WeatherAPIResponse: Codable {
    let main: WeatherMain
    let wind: WeatherWind
    let weather: [WeatherDescription]
}

struct WeatherMain: Codable {
    let temp: Double
    let humidity: Int
}

struct WeatherWind: Codable {
    let speed: Double
}

struct WeatherDescription: Codable {
    let description: String
}

struct WeatherView: View {
    let weatherData: WeatherData
    
    var body: some View {
        VStack {
            Text("Temperature: \(weatherData.temperature)°C")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Humidity: \(weatherData.humidity)%")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Wind Speed: \(weatherData.windSpeed) km/h")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Description: \(weatherData.description)")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
    }
}

struct WeatherData {
    let temperature: String
    let humidity: String
    let windSpeed: String
    let description: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
