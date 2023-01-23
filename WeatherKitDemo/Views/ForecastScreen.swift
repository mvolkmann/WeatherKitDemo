import SwiftUI
import WeatherKit

struct ForecastScreen: View {
    @Environment(
        \.verticalSizeClass
    ) var verticalSizeClass: UserInterfaceSizeClass?

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
    private let temperatureWidth = 50.0
    private let windWidth = 65.0
    private let precipitationWidth = 45.0

    // MARK: - Properties

    private let dateFormatter = DateFormatter()
    private let measurementFormatter = MeasurementFormatter()

    private var header: some View {
        HStack(spacing: 8) {
            Text("Day/Time").frame(width: dateWidth)
            Text("").frame(width: symbolWidth)
            Text("Temp").frame(width: temperatureWidth)
            Text("Wind").frame(width: windWidth)
            Text("Prec").frame(width: precipitationWidth)
            Spacer()
        }
        .fontWeight(.bold)
        .padding(.leading)
        .frame(maxWidth: .infinity)
    }

    private var width: CGFloat {
        verticalSizeClass == .compact ? 350 : .infinity
    }

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
            .frame(maxWidth: width)
        }
        .onRotate { orientation = $0 }
    }

    // MARK: - Methods

    private func forecastView(_ forecast: HourWeather) -> some View {
        HStack {
            // TODO: Use 24-hour clock in French without AM/PM.
            Text(dateFormatter.string(from: forecast.date))
                .frame(width: dateWidth, alignment: .leading)

            Image.symbol(symbolName: forecast.symbolName, size: 30)
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

        // print("precipitation amount =", forecast.precipitationAmount)
        // TODO: Report in centimeters for metric languages.
        let amount = forecast.precipitationAmount.converted(to: .inches)
        // print("precipitation inches =", amount)
        let amountText = amount.value < 0.1 ?
            "trace" :
            String(format: "%.1f", amount.value) + " " + amount.unit.symbol

        return description + " " + amountText
    }
}
