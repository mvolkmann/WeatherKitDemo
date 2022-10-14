import SwiftUI
import WeatherKit

struct ForecastScreen: View {
    // MARK: - Initializer

    init() {
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE h:a")
    }

    // MARK: - State

    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    // MARK: - Constants

    private let dateWidth = 95.0
    private let symbolWidth = 30.0
    private let temperatureWidth = 50.0
    private let windWidth = 65.0
    private let precipitationWidth = 45.0

    // MARK: - Properties

    private let dateFormatter = DateFormatter()

    private var formattedTemperature: String {
        guard let temperature = weatherVM.summary?.temperature
        else { return "" }
        return format(temperature: temperature)
    }

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

    var body: some View {
        Template {
            if let summary = weatherVM.summary {
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
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }

    // MARK: - Methods

    private func forecastView(_ forecast: HourWeather) -> some View {
        HStack {
            Text(dateFormatter.string(from: forecast.date))
                .frame(width: dateWidth)
            Image.symbol(symbolName: forecast.symbolName, size: 30)
                .frame(width: symbolWidth)
            Text(format(
                temperature: forecast.temperature.converted(to: .fahrenheit)
            ))
            .frame(width: temperatureWidth)
            Text(forecast.wind.speed.formatted())
                .frame(width: windWidth)
            Text(forecast.precipitation.description)
                .frame(width: precipitationWidth)
        }
    }

    private func format(temperature: Measurement<UnitTemperature>) -> String {
        String(format: "%.0f", temperature.value) + temperature.unit.symbol
    }
}
