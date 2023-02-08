import CoreLocation
import SwiftUI
import WeatherKit

private let bluePercent = 2.0 / 3.0
private let redPercent = 0.0

class WeatherViewModel: NSObject, ObservableObject {
    // MARK: - State

    @AppStorage("showAbsoluteColors") private var showAbsoluteColors = false
    @AppStorage("chartDays") private var chartDays = WeatherService.days
    @AppStorage("showFahrenheit") private var showFahrenheit: Bool?
    @AppStorage("showFeel") private var showFeel = false
    @AppStorage("showHeatMapDaysOnTop") private var showHeatMapDaysOnTop = false

    @Published var dateToTemperatureMap: [Date: Measurement<UnitTemperature>] =
        [:]
    @Published var heatMapDaysOnTop = false
    @Published var slow = false
    @Published var summary: WeatherSummary?
    @Published var timestamp: Date?
    @Published var useFahrenheit = false

    // This is a singleton class.
    static let shared = WeatherViewModel()
    override private init() {}

    // MARK: - Properties

    // var loadingLocation: CLLocation?

    var fiveDayForecast: [HourWeather] {
        guard let forecasts = summary?.hourlyForecast, !forecasts.isEmpty else {
            return []
        }
        let index = forecasts.firstIndex { $0.date >= Date.now } ?? 0
        let count = WeatherService.days * 24
        let fiveDays = forecasts.dropFirst(index).prefix(count)
        return Array(fiveDays)
    }

    // Returns the highest temperature in Fahrenheit over the next five days.
    var forecastTempMax: Double {
        let forecasts = fiveDayForecast
        guard !forecasts.isEmpty else { return 100.0 }
        let forecast = forecasts.max {
            $0.temperature.value < $1.temperature.value
        }
        return forecast!.fahrenheit
    }

    // Returns the lowest temperature in Fahrenheit over the next five days.
    var forecastTempMin: Double {
        let forecasts = fiveDayForecast
        guard !forecasts.isEmpty else { return 0.0 }
        let forecast = forecasts.min {
            $0.temperature.value < $1.temperature.value
        }
        return forecast!.fahrenheit
    }

    var formattedTimestamp: String {
        guard let timestamp else { return "" }

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }

    var futureForecast: [HourWeather] {
        guard let summary else { return [] }

        // The array summary.hourlyForecast holds
        // forecasts starting at the beginning of the day.
        // Drop the forecasts at the beginning for past hours.
        let hour = Calendar.current.component(.hour, from: Date.now)
        let forecasts = summary.hourlyForecast.dropFirst(hour + 1)

        return Array(forecasts)
    }

    // Returns a color gradient from the lowest to highest temperatures
    // over the next five days, taking into account whether
    // an absolute or relative scale should be used.
    var gradient: Gradient {
        let tempMin = max(forecastTempMin, 0)
        let tempMax = min(forecastTempMax, 100)

        // We want these values to range from
        // bluePercent for the coldest to redPercent for the warmest.
        let realStart = showAbsoluteColors ?
            bluePercent - bluePercent * tempMax / 100 : redPercent
        let realEnd = showAbsoluteColors ?
            bluePercent - bluePercent * tempMin / 100 : bluePercent

        // red has a hue of zero and blue has hue of 2/3.
        // "by" is negative so the gradient goes from blue to red.
        let hueColors = stride(
            from: realEnd, // blue-ish
            to: realStart, // red-ish
            by: -0.01
        ).map {
            color(forHue: $0)
        }
        return Gradient(colors: hueColors)
    }

    var temperatureUnitSymbol: String { useFahrenheit ? "℉" : "℃" }

    // MARK: - Methods

    private func color(forHue hue: Double) -> Color {
        Color(hue: hue, saturation: 0.8, brightness: 0.8)
    }

    // Returns the Color to display for a given temperature.
    func color(temperature: Double) -> Color {
        let tempMin = max(forecastTempMin, 0)
        let tempMax = min(forecastTempMax, 100)

        let realStart = showAbsoluteColors ?
            bluePercent - bluePercent * tempMax / 100 : redPercent
        let realEnd = showAbsoluteColors ?
            bluePercent - bluePercent * tempMin / 100 : bluePercent
        let percent = max(temperature - tempMin, 0) / (tempMax - tempMin)
        let hue = realEnd - percent * (realEnd - realStart)
        return color(forHue: hue)
    }

    func load(location: CLLocation, colorScheme: ColorScheme) async throws {
        /*
         // This logic for avoiding duplicate weather lookups
         // sometimes results in no weather data being fetched
         // and I don't know why.
         if let loadingLocation {
             if location.description == loadingLocation.description {
                 return
             }
         }

         loadingLocation = location
         defer { loadingLocation = nil }
         */

        // If WeatherKit takes more than 5 seconds to return data,
        // consider it slow.
        let waitSeconds = 5.0
        DispatchQueue.main.asyncAfter(deadline: .now() + waitSeconds) {
            if self.summary == nil { self.slow = true }
        }

        await MainActor.run {
            // Initialize to values from AppStorage.
            heatMapDaysOnTop = showHeatMapDaysOnTop
            useFahrenheit = showFahrenheit ??
                (LocationViewModel.shared.country == "United States")

            summary = nil
        }

        // This method is defined in WeatherServiceExtension.swift.
        let weatherSummary = try await WeatherService.shared.summary(
            for: location,
            colorScheme: colorScheme
        )

        Task { @MainActor in
            summary = weatherSummary
            slow = false

            dateToTemperatureMap = [:]
            if let forecasts = summary?.hourlyForecast {
                for forecast in forecasts {
                    dateToTemperatureMap[forecast.date] = forecast.temperature
                }
            }

            timestamp = Date.now
        }
    }
}
