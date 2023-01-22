import Foundation // for Date
import WeatherKit

extension HourWeather: Hashable, Identifiable {
    /// Temperature in Celsius or Fahrenheit based on the value of `showFahrenheit`.
    var converted: Double {
        temperature.converted
    }

    var fahrenheit: Double {
        temperature.converted(to: .fahrenheit).value
    }

    public var id: Date {
        date
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
}
