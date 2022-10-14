import SwiftUI

class WeatherViewModel: NSObject, ObservableObject {
    @Published var dateToFahrenheitMap: [Date: Double] = [:]

    @Published var summary: WeatherSummary? {
        willSet {
            dateToFahrenheitMap = [:]
            if let hours = newValue?.hourlyForecast {
                for hour in hours {
                    let celsius = hour.temperature
                    dateToFahrenheitMap[hour.date] = celsius.converted(
                        to: UnitTemperature.fahrenheit
                    ).value
                }
            }
        }
    }

    // This is a singleton class.
    static let shared = WeatherViewModel()
    override private init() {}
}
