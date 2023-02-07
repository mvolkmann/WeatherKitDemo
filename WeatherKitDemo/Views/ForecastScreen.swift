import SwiftUI
import WeatherKit

struct ForecastScreen: View {
    // MARK: - State

    // @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(
        \.horizontalSizeClass
    ) var horizontalSizeClass: UserInterfaceSizeClass?

    // MARK: - Initializer

    init() {
        // For dates, show the abbreviated day of week and time.
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE h:a")
        // Use the time zone of the selected location.
        dateFormatter.timeZone = LocationViewModel.shared.timeZone

        measurementFormatter.numberFormatter.maximumFractionDigits = 0
    }

    // MARK: - State

    @StateObject private var weatherVM = WeatherViewModel.shared

    // MARK: - Constants

    private let dateWidth = 95.0
    private let symbolWidth = 30.0
    private let windWidth = 65.0

    // MARK: - Properties

    private let dateFormatter = DateFormatter()
    private let measurementFormatter = MeasurementFormatter()

    private var futureForecasts: [HourWeather] {
        guard let forecasts = weatherVM.summary?.hourlyForecast else {
            return []
        }

        let dropCountBegin = forecasts.firstIndex { $0.date > Date.now } ?? 0
        let dropCountEnd =
            forecasts.count - dropCountBegin - WeatherService.days * 24
        let result = Array(
            forecasts.dropFirst(dropCountBegin).dropLast(dropCountEnd)
        )
        return result
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("Day/Time").frame(width: dateWidth)
            Text("").frame(width: symbolWidth)
            Text("Temp").frame(width: temperatureWidth)
            Text("Wind").frame(width: windWidth)
            Text(isWide ? "Precip" : "Prec")
                .frame(width: precipitationWidth)
            Spacer()
        }
        .font(.subheadline)
        .fontWeight(.bold)
        .padding(.leading)
    }

    private var isWide: Bool { horizontalSizeClass != .compact }

    private var listWidth: Double {
        let extra = 25.0
        return extra + dateWidth + symbolWidth + temperatureWidth + windWidth +
            precipitationWidth + extra
    }

    private var precipitationWidth: Double { isWide ? 110 : 45 }

    private var temperatureWidth: Double { isWide ? 120 : 55 }

    var body: some View {
        Template {
            VStack {
                header.padding(.top)
                List {
                    ForEach(futureForecasts) { forecastRow($0) }
                }
                .listStyle(.plain)
                .cornerRadius(10)
            }
            .frame(maxWidth: isWide ? listWidth : .infinity)
        }
    }

    // MARK: - Methods

    private func forecastRow(_ forecast: HourWeather) -> some View {
        HStack {
            // This honors the Settings ... General ...
            // Date & Time ... 24-Hour Time switch.
            Text(dateFormatter.string(from: forecast.date))
                .dynamicTypeSize(...DynamicTypeSize.medium) // not working!
                .frame(width: dateWidth, alignment: .leading)

            Image.symbol(symbolName: forecast.symbolName)
                .frame(width: symbolWidth)

            Text(formatTemperature(forecast: forecast))
                .dynamicTypeSize(...DynamicTypeSize.medium) // not working!
                .foregroundColor(Color(UIColor.systemBackground))
                .frame(width: temperatureWidth)
                .padding(.vertical, 5)
                .background(
                    weatherVM.color(temperature: forecast.fahrenheit)
                )

            Text(measurementFormatter.string(from: forecast.wind.speed))
                .dynamicTypeSize(...DynamicTypeSize.medium) // not working!
                .frame(width: windWidth)

            Text(precipitationReport(forecast))
                .dynamicTypeSize(...DynamicTypeSize.medium) // not working!
                .frame(width: precipitationWidth)
        }
        .dynamicTypeSize(...DynamicTypeSize.medium) // not working!
    }

    private func formatTemperature(forecast: HourWeather) -> String {
        let temperature = weatherVM.useFeel ?
            forecast.apparentTemperature : forecast.temperature
        return String(format: "%.0f", temperature.converted) +
            weatherVM.temperatureUnitSymbol
    }

    private func precipitationReport(_ forecast: HourWeather) -> String {
        let description = forecast.precipitation.description
        // guard !description.isEmpty else { return "none".localized }
        guard !description.isEmpty else { return "-" }

        let unit: UnitLength = Locale.current.region?.identifier == "US" ?
            .inches : .centimeters
        let amount = forecast.precipitationAmount.converted(to: unit)

        var value = amount.value // "liquid equivalent"

        // The baseline ratio of rain to snow is
        // 1 inch of rain equals 10 inches of snow.
        if description == "snow" { value *= snowMultiplier(forecast) }

        let amountText = value < 0.1 ? "trace" :
            String(format: "%.1f", value) + " " + amount.unit.symbol

        return "\(amountText) \(description)"
    }

    // These numbers come from
    // https://sciencing.com/calculate-ratio-between-two-numbers-8187157.html.
    private func snowMultiplier(_ forecast: HourWeather) -> Double {
        let fahrenheit = forecast.temperature.converted(to: .fahrenheit).value
        if fahrenheit >= 27 { return 10 }
        if fahrenheit >= 20 { return 15 }
        if fahrenheit >= 15 { return 20 }
        if fahrenheit >= 10 { return 30 }
        if fahrenheit >= 0 { return 40 }
        if fahrenheit >= -20 { return 50 }
        return 100
    }
}
