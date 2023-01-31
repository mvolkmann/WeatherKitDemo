import CoreLocation
import SwiftUI
import WeatherKit

class WeatherViewModel: NSObject, ObservableObject {
    @AppStorage("showFahrenheit") var showFahrenheit = false
    @AppStorage("showFeel") var showFeel = false

    @Published var dateToTemperatureMap: [Date: Measurement<UnitTemperature>] =
        [:]
    @Published var useFeel = false
    @Published var useFahrenheit = false
    @Published var summary: WeatherSummary?
    @Published var timestamp: Date?

    // This is a singleton class.
    static let shared = WeatherViewModel()
    override private init() {}

    var formattedTimestamp: String {
        guard let timestamp else { return "" }

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }

    var futureForecast: [HourWeather] {
        guard let summary else { return [] }
        let now = Date()
        return summary.hourlyForecast.filter { $0.date >= now }
    }

    var temperatureUnitSymbol: String { useFahrenheit ? "℉" : "℃" }

    func load(location: CLLocation, colorScheme: ColorScheme) async throws {
        await MainActor.run {
            // Initialize to values from AppStorage.
            useFahrenheit = showFahrenheit
            useFeel = showFeel

            summary = nil
        }

        // This method is defined in WeatherServiceExtension.swift.
        let weatherSummary = try await WeatherService.shared.summary(
            for: location,
            colorScheme: colorScheme
        )

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
