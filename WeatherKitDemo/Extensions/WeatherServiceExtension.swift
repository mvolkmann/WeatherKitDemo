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
        print("WeatherServiceExtension.summary: location =", location)
        let weather = try await weather(for: location)
        let current = weather.currentWeather

        let wind = current.wind
        let windSpeed = wind.speed.formatted()
        let windDirection = wind.compassDirection

        let forecast = await hourlyForecast(for: location)

        // Only keep forecasts from midnight this morning
        // to a given number of days in the future.
        var startDate = Date().startOfDay
        let hourOffset = timeZoneOffset(date: startDate)
        startDate = startDate.hoursAfter(hourOffset)

        let endDate = startDate.addingTimeInterval(
            Double((Self.days * 24 - 1) * 60 * 60)
        )

        let keepForecast = forecast.filter {
            startDate <= $0.date && $0.date <= endDate
        }

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
        if let targetSeconds {
            return (targetSeconds - currentSeconds) / 60 / 60
        }
        return 0
    }
}
