import CoreLocation
import SwiftUI
import WeatherKit

extension WeatherService {
    func hourlyForecast(for location: CLLocation) async -> [HourWeather] {
        let forecast = try? await weather(
            for: location,
            including: .hourly
        )
        return forecast?.forecast ?? []
    }

    func summary(
        for location: CLLocation,
        colorScheme: ColorScheme
    ) async throws -> WeatherSummary {
        let weather = try await weather(for: location)
        let current = weather.currentWeather

        let wind = current.wind
        let windSpeed = wind.speed.formatted()
        let windDirection = wind.compassDirection

        let forecast = await hourlyForecast(for: location)
        // Keep only the forecasts in the future.
        let now = Date()
        let futureForecast = forecast.filter { $0.date > now }

        let attr = try await attribution
        let logoURL = colorScheme == .light ?
            attr.combinedMarkLightURL : attr.combinedMarkDarkURL

        return WeatherSummary(
            condition: current.condition.description,
            symbolName: current.symbolName,
            temperature: current.temperature.converted(to: .fahrenheit),
            wind: "\(windSpeed) from \(windDirection)",
            hourlyForecast: futureForecast,
            attributionLogoURL: logoURL,
            attributionPageURL: attr.legalPageURL
        )
    }
}
