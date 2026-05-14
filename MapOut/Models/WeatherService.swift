import Foundation
import CoreLocation
import SwiftUI
import Combine

struct WeatherData {
    let temperature: Double
    let weatherCode: Int
    let windSpeed: Double
    let humidity: Int

    var icon: String {
        switch weatherCode {
        case 0: return "sun.max.fill"
        case 1, 2, 3: return "cloud.sun.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55, 61, 63, 65: return "cloud.rain.fill"
        case 71, 73, 75: return "cloud.snow.fill"
        case 80, 81, 82: return "cloud.heavyrain.fill"
        case 95: return "cloud.bolt.fill"
        default: return "cloud.fill"
        }
    }

    var description: String {
        switch weatherCode {
        case 0: return "Clear Sky"
        case 1, 2, 3: return "Partly Cloudy"
        case 45, 48: return "Foggy"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rainy"
        case 71, 73, 75: return "Snowy"
        case 80, 81, 82: return "Heavy Rain"
        case 95: return "Thunderstorm"
        default: return "Cloudy"
        }
    }

    var color: Color {
        switch weatherCode {
        case 0: return .orange
        case 1, 2, 3: return .blue
        case 61, 63, 65, 80, 81, 82: return .indigo
        case 71, 73, 75: return .cyan
        case 95: return .purple
        default: return .gray
        }
    }
}

class WeatherService: ObservableObject {
    @Published var weather: WeatherData? = nil
    @Published var isLoading = false
    @Published var error: String? = nil

    func fetchWeather(for location: String, on date: Date) async {
        await MainActor.run { isLoading = true }

        let geocoder = CLGeocoder()
        guard let placemark = try? await geocoder.geocodeAddressString(location).first,
              let coordinate = placemark.location?.coordinate else {
            await MainActor.run {
                error = "Could not find location"
                isLoading = false
            }
            return
        }

        let dateStr = ISO8601DateFormatter().string(from: date).prefix(10)
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)&daily=weathercode,temperature_2m_max,windspeed_10m_max&timezone=auto&start_date=\(dateStr)&end_date=\(dateStr)"

        guard let url = URL(string: urlStr),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let daily = json["daily"] as? [String: Any],
              let codes = daily["weathercode"] as? [Int],
              let temps = daily["temperature_2m_max"] as? [Double],
              let winds = daily["windspeed_10m_max"] as? [Double]
        else {
            await MainActor.run {
                error = "Could not fetch weather"
                isLoading = false
            }
            return
        }

        let weatherData = WeatherData(
            temperature: temps.first ?? 0,
            weatherCode: codes.first ?? 0,
            windSpeed: winds.first ?? 0,
            humidity: 0
        )

        await MainActor.run {
            weather = weatherData
            isLoading = false
        }
    }
}
