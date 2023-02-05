import CoreLocation
import SwiftUI
import WeatherKit

extension WeatherService {
    static let days = 5

    func hourlyForecast(for location: CLLocation) async -> [HourWeather] {
        let forecast = try? await weather(
            for: location,
            including: .hourly
        )
        return forecast?.forecast ?? []
    }

    func summary(
        for location: CLLocation,
        colorScheme _: ColorScheme
    ) async throws -> WeatherSummary {
        // The daily forecasts always start at midnight
        // in the timezone of the location you specify.
        let weather = try await weather(for: location)
        let current = weather.currentWeather

        let wind = current.wind
        let windSpeed = wind.speed.formatted()
        let windDirection = wind.compassDirection

        let forecast = await hourlyForecast(for: location)

        // Only keep forecasts from midnight this morning
        // to a given number of days in the future.

        /*
         let timeZone = try await LocationViewModel.shared.getTimeZone()
         print("timeZone: \(timeZone.identifier)")
         let secondsFrom = timeZone.secondsFromGMT(for: Date())
         print("secondsFrom: \(secondsFrom)")

         // TODO: Get start of day for date in location!
         let now = Date()
         var startDate = secondsFrom > 0 ? now.tomorrow : now
         startDate = startDate.startOfDay
         print("startDate: \(startDate)")
         let hourOffset = timeZoneOffset(date: startDate)
         print("hourOffset: \(hourOffset)")
         startDate = startDate.hoursAfter(hourOffset)
         */
        var startDate = Date().startOfDay

        let endDate = startDate.addingTimeInterval(
            Double((Self.days * 24 - 1) * 60 * 60)
        )

        let keepForecast = forecast.filter {
            startDate <= $0.date && $0.date <= endDate
        }

        /*
         let firstForecast = keepForecast.first!
         print("date =", firstForecast.date)
         print("temperature F =", firstForecast.temperature.fahrenheit)
         */

        let attr = try await attribution

        return WeatherSummary(
            condition: current.condition.description,
            symbolName: current.symbolName,
            temperature: current.temperature,
            apparentTemperature: current.apparentTemperature,
            wind: "\(windSpeed) from \(windDirection)",
            hourlyForecast: keepForecast,
            attributionLightLogoURL: attr.combinedMarkLightURL,
            attributionDarkLogoURL: attr.combinedMarkDarkURL,
            attributionPageURL: attr.legalPageURL
        )
    }

    private func timeZoneOffset(date: Date) -> Int {
        let currentSeconds = TimeZone.current.secondsFromGMT(for: date)
        let locationVM = LocationViewModel.shared
        let targetSeconds = locationVM.timeZone?.secondsFromGMT(for: date)
        guard let targetSeconds else { return 0 }
        return (targetSeconds - currentSeconds) / 60 / 60
    }
}
