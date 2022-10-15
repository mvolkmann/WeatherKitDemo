import CoreLocation
import SwiftUI
import WeatherKit

class WeatherViewModel: NSObject, ObservableObject {
    @Environment(\.colorScheme) private var colorScheme

    @Published var dateToFahrenheitMap: [Date: Double] = [:]

    @Published var summary: WeatherSummary?

    // This is a singleton class.
    static let shared = WeatherViewModel()
    override private init() {}

    func load(location: CLLocation) async throws {
        summary = try await WeatherService.shared.summary(
            for: location,
            colorScheme: colorScheme
        )
        // print("summary =", weatherVM.summary)

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
