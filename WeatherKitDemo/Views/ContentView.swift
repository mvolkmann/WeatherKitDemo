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

    @StateObject private var locationService = LocationService()

    // MARK: - Properties

    let dateFormatter = DateFormatter()

    let weatherService = WeatherService.shared

    var body: some View {
        VStack {
            Text("WeatherKitDemo").font(.largeTitle)
            if let summary {
                Image.symbol(symbolName: summary.symbolName)
                Text("Condition: \(summary.condition)")
                Text("Temperature: \(summary.temperature)")
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
                    ForEach(
                        summary.hourlyForecast,
                        id: \.self
                    ) { forecast in
                        forecastView(forecast)
                    }
                }
                .listStyle(.plain)
            } else {
                ProgressView()
            }
        }
        .padding()
        .task(id: locationService.currentLocation) {
            do {
                if let location = locationService.currentLocation {
                    print("location =", location)
                    // TODO: Can you get the associated city?
                    summary = try await weatherService.summary(
                        for: location,
                        colorScheme: colorScheme
                    )
                }
            } catch {
                print("ContentView.body: error =", error)
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
            // Text(forecast.condition)
            Text(forecast.temperature.formatted())
                .frame(width: 60)
            Text(forecast.wind.speed.formatted())
                .frame(width: 60)
            Text(forecast.precipitationAmount.formatted())
                .frame(width: 50)
        }
    }
}
