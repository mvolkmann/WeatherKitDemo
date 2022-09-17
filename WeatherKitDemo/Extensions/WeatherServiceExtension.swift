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

        print("daily forecast =", weather.dailyForecast)

        let current = weather.currentWeather

        let windDescription = current.wind.speed
        let windDirection = current.wind.compassDirection
        // let windDescription = current.wind.speed.convert(to: Unit("mi/hr"))
        let wind = "\(windDescription) from the \(windDirection)"

        let forecast = await hourlyForecast(for: location)

        let attr = try await attribution
        let logoURL = colorScheme == .light ?
            attr.combinedMarkLightURL : attr.combinedMarkDarkURL

        return WeatherSummary(
            condition: current.condition.description,
            symbolName: current.symbolName,
            temperature: current.temperature.converted(to: .fahrenheit),
            wind: wind,
            hourlyForecast: forecast,
            attributionLogoURL: logoURL,
            attributionPageURL: attr.legalPageURL
        )
    }
}
