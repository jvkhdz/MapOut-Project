//
//  WeatherCardView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 29.04.26.
//

import SwiftUI

struct WeatherCardView: View {
    let location: String
    let date: Date
    @StateObject private var service = WeatherService()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Weather Forecast", systemImage: "cloud.sun.fill")
                .font(.title3).bold()

            if service.isLoading {
                HStack {
                    ProgressView()
                    Text("Fetching weather...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else if let weather = service.weather {
                HStack(spacing: 16) {
                    Image(systemName: weather.icon)
                        .font(.largeTitle)
                        .foregroundStyle(weather.color)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(weather.temperature))°C")
                            .font(.title2)
                            .bold()
                        Text(weather.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(location)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Label("\(Int(weather.windSpeed)) km/h", systemImage: "wind")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else if let error = service.error {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
        .task {
            await service.fetchWeather(for: location, on: date)
        }
    }
}

#Preview {
    WeatherCardView(location: "Paris", date: Date())
        .padding()
}
