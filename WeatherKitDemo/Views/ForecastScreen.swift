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
            Text(isWide ? "Temperature" : "Temp").frame(width: temperatureWidth)
            Text(isWide ? "Wind Speed" : "Wind").frame(width: windWidth)
            Text(isWide ? "Precipitation" : "Prec")
                .frame(width: precipitationWidth)
            Spacer()
        }
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

    private var temperatureWidth: Double { isWide ? 120 : 50 }

    var body: some View {
        Template {
            VStack {
                header.padding(.top)
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

            Text(format(forecast: forecast))
                .frame(width: temperatureWidth)

            Text(measurementFormatter.string(from: forecast.wind.speed))
                .frame(width: windWidth)

            Text(precipitationReport(forecast))
                .frame(width: precipitationWidth)
        }
    }

    private func format(forecast: HourWeather) -> String {
        return String(format: "%.0f", forecast.converted) +
            weatherVM.temperatureUnitSymbol
    }

    private func precipitationReport(_ forecast: HourWeather) -> String {
        let description = forecast.precipitation.description
        guard !description.isEmpty else { return "none".localized }

        let unit: UnitLength = Locale.current.region?.identifier == "US" ?
            .inches : .centimeters
        let amount = forecast.precipitationAmount.converted(to: unit)

        var value = amount.value // "liquid equivalent"

        // The baseline ratio of rain to snow is
        // 1 inch of rain equals 10 inches of snow.
        if description == "snow" { value *= 10 }

        let amountText = value < 0.1 ? "trace" :
            String(format: "%.1f", value) + " " + amount.unit.symbol

        return "\(amountText) \(description)"
    }
}
