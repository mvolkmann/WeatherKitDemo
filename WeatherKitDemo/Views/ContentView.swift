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

    @StateObject private var locationVM = LocationViewModel()

    // MARK: - Properties

    private let dateFormatter = DateFormatter()

    private var formattedTemperature: String {
        guard let temperature = summary?.temperature else { return "" }
        return format(temperature: temperature)
    }

    private let weatherService = WeatherService.shared

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            VStack {
                Text("WeatherKitDemo")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                if let summary {
                    Group {
                        Image.symbol(symbolName: summary.symbolName)
                        Text(
                            "Location: \(locationVM.city), \(locationVM.state)"
                        )
                        Text("Condition: \(summary.condition)")
                        Text("Temperature: \(formattedTemperature)")
                        Text("Winds \(summary.wind)")
                        // TODO: Why doesn't the color of this update when the colorScheme changes?
                        Link(destination: summary.attributionPageURL) {
                            AsyncImage(
                                url: summary.attributionLogoURL,
                                content: { image in image.resizable() },
                                placeholder: { ProgressView() }
                            )
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                        }
                    }
                    .foregroundColor(.primary)
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
                    .padding(.top)
                } else {
                    ProgressView()
                }
            }
            .padding()
        }

        // Run this closure again the location is determined.
        .task(id: locationVM.location) {
            if let location = locationVM.location {
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
