import CoreLocation
import SwiftUI
import WeatherKit

class WeatherViewModel: NSObject, ObservableObject {
    @AppStorage("showFahrenheit") var showFahrenheit = false

    @Published var dateToTemperatureMap: [Date: Measurement<UnitTemperature>] =
        [:]
    @Published var useFahrenheit = false
    @Published var summary: WeatherSummary?
    @Published var timestamp: Date?

    // This is a singleton class.
    static let shared = WeatherViewModel()
    override private init() {}

    var formattedTimestamp: String {
        guard let timestamp else { return "" }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: timestamp)
    }

    var futureForecast: [HourWeather] {
        let now = Date()
        guard let summary else { return [] }
        return summary.hourlyForecast.filter { $0.date >= now }
    }

    func load(location: CLLocation, colorScheme: ColorScheme) async throws {
        await MainActor.run {
            // Initialize to value from AppStorage.
            useFahrenheit = showFahrenheit

            summary = nil
        }

        // This method is defined in WeatherServiceExtension.swift.
        let weatherSummary = try await WeatherService.shared.summary(
            for: location,
            colorScheme: colorScheme
        )
        // print("weatherSummary =", weatherSummary)

        await MainActor.run {
            summary = weatherSummary

            dateToTemperatureMap = [:]
            if let forecasts = summary?.hourlyForecast {
                for forecast in forecasts {
                    dateToTemperatureMap[forecast.date] = forecast.temperature
                }
            }
        }

        Task {
            await MainActor.run { self.timestamp = Date() }
        }
    }
}
