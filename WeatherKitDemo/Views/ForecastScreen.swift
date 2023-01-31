import SwiftUI
import WeatherKit

struct ForecastScreen: View {
    // MARK: - State

    @Environment(
        \.horizontalSizeClass
    ) var horizontalSizeClass: UserInterfaceSizeClass?

    @State private var orientation = UIDeviceOrientation.unknown

    // MARK: - Initializer

    init() {
        // For dates, show the abbreviated day of week and time.
        let use24Hour = Locale.current.identifier.starts(with: "fr")
        let pattern = "EEE " + (use24Hour ? "H" : "h:a")
        dateFormatter.setLocalizedDateFormatFromTemplate(pattern)

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
                ActualFeelToggle()
                header
                List {
                    ForEach(
                        weatherVM.futureForecast,
                        id: \.self
                    ) { forecast in
                        forecastView(forecast)
                    }
                }
                .listStyle(.plain)
                .cornerRadius(10)
            }
            .frame(maxWidth: isWide ? listWidth : .infinity)
        }
        .onRotate { orientation = $0 }
    }

    // MARK: - Methods

    private func forecastView(_ forecast: HourWeather) -> some View {
        HStack {
            // TODO: Use 24-hour clock in French without AM/PM.
            Text(dateFormatter.string(from: forecast.date))
                .frame(width: dateWidth, alignment: .leading)

            Image.symbol(symbolName: forecast.symbolName)
                .frame(width: symbolWidth)

            Text(formatTemperature(forecast: forecast))
                .frame(width: temperatureWidth)

            Text(measurementFormatter.string(from: forecast.wind.speed))
                .frame(width: windWidth)

            Text(precipitationReport(forecast))
                .frame(width: precipitationWidth)
        }
    }

    private func formatTemperature(forecast: HourWeather) -> String {
        let temperature = weatherVM.showFeel ?
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
