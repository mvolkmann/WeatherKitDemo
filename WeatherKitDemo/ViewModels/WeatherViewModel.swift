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
    @AppStorage("heatMapDaysOnTop") private var heatMapDaysOnTop = false

    // This is used by ChartScreen.
    @Published var dateToTemperatureMap: [Date: Measurement<UnitTemperature>] =
        [:]

    @Published var dayWeather: DayWeather?

    // When true a message is displayed that informs the user
    // that WeatherKit is taking longer than usual to return data.
    @Published var isSlow = false

    @Published var summary: WeatherSummary?

    // This holds the timestamp of the last time
    // data was obtained from WeatherKit.
    @Published var timestamp: Date?

    // This is a singleton class.
    static let shared = WeatherViewModel()
    override private init() {}

    // MARK: - Properties

    var fiveDayForecast: [HourWeather] {
        guard let forecasts = summary?.hourlyForecast, !forecasts.isEmpty else {
            return []
        }
        let index = forecasts.firstIndex { $0.date >= Date.current } ?? 0
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
        let hour = Calendar.current.component(.hour, from: Date.current)
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

    var temperatureUnitSymbol: String { showFahrenheit == true ? "℉" : "℃" }

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
        // If WeatherKit takes more than 5 seconds to return data,
        // consider it slow.
        let waitSeconds = 5.0
        DispatchQueue.main.asyncAfter(deadline: .now() + waitSeconds) {
            if self.summary == nil { self.isSlow = true }
        }

        await MainActor.run {
            if showFahrenheit == nil {
                showFahrenheit =
                    LocationViewModel.shared.country == "United States"
            }

            // Clear this while gathering weather data for a new location.
            summary = nil
        }

        // This is used to create Data/weather-summary.json
        // which is used in tests instead of making calls to WeatherKit.
        // dumpJSON(weatherSummary)

        #if targetEnvironment(simulator)
            print("WeatherViewModel: loading from JSON")
            let weatherSummary = loadFromJSON()
            let dayWeatherTemp = nil // TODO: Load from JSON.
        #else
            print("WeatherViewModel: loading from WeatherKit")
            let weatherSummary = try await WeatherService.shared.summary(
                for: location,
                colorScheme: colorScheme
            )

            let dayWeatherTemp = try await WeatherService.shared.dayWeather(
                for: location
            )
        #endif

        Task { @MainActor in
            summary = weatherSummary
            dayWeather = dayWeatherTemp
            isSlow = false

            dateToTemperatureMap = [:]
            if let forecasts = summary?.hourlyForecast {
                for forecast in forecasts {
                    dateToTemperatureMap[forecast.date] = forecast
                        .temperature
                }
            }

            timestamp = Date.current
        }
    }

    // This is used to capture the weather summary as JSON
    // so it can be used in tests and avoid using WeatherKit.
    func dumpJSON(_ summary: WeatherSummary) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(summary)
            if let json = String(data: encoded, encoding: .utf8) {
                print(json)
            } else {
                print("WeatherViewModel.load: failed to encode JSON")
            }
        } catch {
            print("WeatherViewModel.load: failed to save JSON")
        }
    }

    func loadFromJSON() -> WeatherSummary {
        Bundle.main.decode(
            WeatherSummary.self,
            from: "weather-summary.json"
        )
    }
}
