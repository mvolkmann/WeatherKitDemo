import SwiftUI
import WeatherKit

struct Temperature {
    @AppStorage("showFahrenheit") static var showFahrenheit = false

    /// Returns temperature in Celsius or Fahrenheit based on the value of `showFahrenheit`.
    static func toDouble(_ forecast: HourWeather) -> Double {
        toDouble(forecast.temperature)
    }

    /// Returns temperature in Celsius or Fahrenheit based on the value of `showFahrenheit`.
    static func toDouble(
        _ temperature: Measurement<UnitTemperature>
    ) -> Double {
        temperature.converted(to: showFahrenheit ? .fahrenheit : .celsius).value
    }

    static func toFahrenheit(_ forecast: HourWeather) -> Double {
        forecast.temperature.converted(to: .fahrenheit).value
    }

    static var unit: String { showFahrenheit ? "℉" : "℃" }
}
