import Foundation // for Date
import WeatherKit

extension HourWeather: Hashable, Identifiable {
    public var id: Date {
        date
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
}
