import CoreLocation
import SwiftUI
import WeatherKit

struct ContentView: View {
    // MARK: - Initializer

    init() {
        // dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMM d h:a")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE h:a")
    }

    // MARK: - State

    @Environment(\.colorScheme) private var colorScheme

    @State private var summary: WeatherSummary?

    @StateObject private var locationViewModel = LocationViewModel()

    // MARK: - Properties

    private let dateFormatter = DateFormatter()

    private var formattedTemperature: String {
        guard let temperature = summary?.temperature else { return "" }
        return format(temperature: temperature)
    }

    private let weatherService = WeatherService.shared

    var body: some View {
        VStack {
            Text("WeatherKitDemo").font(.largeTitle)
            if let summary {
                Image.symbol(symbolName: summary.symbolName)
                Text("City: \(locationViewModel.city)")
                Text("Condition: \(summary.condition)")
                Text("Temperature: \(formattedTemperature)")
                Text("Winds \(summary.wind)")
                Link(destination: summary.attributionPageURL) {
                    AsyncImage(
                        url: summary.attributionLogoURL,
                        content: { image in image.resizable() },
                        placeholder: { ProgressView() }
                    )
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                }
                List {
                    ForEach(summary.hourlyForecast, id: \.self) { forecast in
                        forecastView(forecast)
                    }
                }
                .listStyle(.plain)
            } else {
                ProgressView()
            }
        }
        .padding()

        // Run this closure again the location is determined.
        .task(id: locationViewModel.location) {
            if let location = locationViewModel.location {
                do {
                    summary = try await weatherService.summary(
                        for: location,
                        colorScheme: colorScheme
                    )
                } catch {
                    print("ContentView error:", error)
                }
            }
        }
    }

    // MARK: - Methods

    private func forecastView(_ forecast: HourWeather) -> some View {
        HStack {
            Text(dateFormatter.string(from: forecast.date))
                .frame(width: 100)
            Image.symbol(symbolName: forecast.symbolName, size: 30)
                .frame(width: 40)
            Text(format(
                temperature: forecast.temperature.converted(to: .fahrenheit)
            ))
            .frame(width: 50)
            Text(forecast.wind.speed.formatted())
                .frame(width: 70)
            Text(forecast.precipitationAmount.formatted())
                .frame(width: 50)
        }
    }

    private func format(temperature: Measurement<UnitTemperature>) -> String {
        String(format: "%.0f", temperature.value) + temperature.unit.symbol
    }
}
