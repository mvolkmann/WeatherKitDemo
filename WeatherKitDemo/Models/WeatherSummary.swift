import Foundation // for URL
import WeatherKit

struct WeatherSummary {
    let condition: String
    let symbolName: String
    let temperature: Measurement<UnitTemperature>
    let wind: String
    let hourlyForecast: [HourWeather]
    let attributionLogoURL: URL
    let attributionPageURL: URL
}
