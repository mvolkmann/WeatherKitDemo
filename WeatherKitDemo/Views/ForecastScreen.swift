import SwiftUI
import WeatherKit

struct ForecastScreen: View {
    @Environment(
        \.verticalSizeClass
    ) var verticalSizeClass: UserInterfaceSizeClass?

    @State private var orientation = UIDeviceOrientation.unknown

    // MARK: - Initializer

    init() {
        // Abbreviated day of week, hour AM/PM
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE h:a")
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
            if let summary = weatherVM.summary {
                VStack {
                    header.padding(.top)
                    List {
                        ForEach(
                            summary.hourlyForecast,
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
        }
        .onRotate { orientation = $0 }
    }

    // MARK: - Methods

    private func forecastView(_ forecast: HourWeather) -> some View {
        HStack {
            Text(dateFormatter.string(from: forecast.date))
                .frame(width: dateWidth)
            Image.symbol(symbolName: forecast.symbolName, size: 30)
                .frame(width: symbolWidth)
            Text(format(temperature: forecast.temperature))
                .frame(width: temperatureWidth)
            Text(forecast.wind.speed.formatted())
                .frame(width: windWidth)
            Text(forecast.precipitation.description)
                .frame(width: precipitationWidth)
        }
    }

    private func format(temperature: Measurement<UnitTemperature>) -> String {
        let fahrenheit = temperature.converted(to: .fahrenheit)
        return String(format: "%.0f", fahrenheit.value) + fahrenheit.unit.symbol
    }
}
