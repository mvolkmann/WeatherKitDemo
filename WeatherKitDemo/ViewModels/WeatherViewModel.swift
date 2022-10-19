import CoreLocation
import SwiftUI
import WeatherKit

class WeatherViewModel: NSObject, ObservableObject {
    @Published var dateToFahrenheitMap: [Date: Double] = [:]
    @Published var summary: WeatherSummary?

    // This is a singleton class.
    static let shared = WeatherViewModel()
    override private init() {}

    var futureForecast: [HourWeather] {
        let now = Date()
        guard let summary else { return [] }
        return summary.hourlyForecast.filter { $0.date >= now }
    }

    func load(location: CLLocation, colorScheme: ColorScheme) async throws {
        await MainActor.run {
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

            dateToFahrenheitMap = [:]
            if let hours = summary?.hourlyForecast {
                for hour in hours {
                    let celsius = hour.temperature
                    dateToFahrenheitMap[hour.date] = celsius.converted(
                        to: UnitTemperature.fahrenheit
                    ).value
                }
            }
        }
    }
}
