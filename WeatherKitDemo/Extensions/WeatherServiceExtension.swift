import CoreLocation
import SwiftUI
import WeatherKit

extension WeatherService {
    static let days = 5

    func summary(
        for location: CLLocation,
        colorScheme _: ColorScheme
    ) async throws -> WeatherSummary {
        // The `Weather` object returned here has a `hourlyForecast` property
        // which has a `forecast` property
        // which is an array of `HourWeather` objects
        // that start at midnight today in the local time zone.
        let myWeather = try await weather(for: location)
        let current = myWeather.currentWeather
        let wind = current.wind
        let windSpeed = wind.speed.formatted()
        let windDirection = wind.compassDirection

        // But we want to start at midnight in the timezone
        // of the given location, so we need another weather query.
        let timeZone = LocationViewModel.shared.timeZone!
        var startDate = timeZone.date.startOfDay

        let currentOffset = TimeZone.current.hoursFromGMT(for: Date.now)
        let targetOffset = LocationViewModel.shared.timeZone?
            .hoursFromGMT(for: Date.now) ?? 0
        let deltaOffset = targetOffset - currentOffset
        startDate = startDate.hoursBefore(deltaOffset)

        // The +1 ensures we have enough data for Self.days
        // regardless of which hour we start on the first day.
        let endDate = startDate.daysAfter(Self.days + 1)
        let query = WeatherQuery.hourly(startDate: startDate, endDate: endDate)
        let myHourlyWeather = try await weather(for: location, including: query)

        let attr = try await attribution

        return WeatherSummary(
            condition: current.condition.description,
            symbolName: current.symbolName,
            temperature: current.temperature,
            apparentTemperature: current.apparentTemperature,
            wind: "\(windSpeed) from \(windDirection)",
            hourlyForecast: myHourlyWeather.forecast,
            attributionLightLogoURL: attr.combinedMarkLightURL,
            attributionDarkLogoURL: attr.combinedMarkDarkURL,
            attributionPageURL: attr.legalPageURL
        )
    }
}
