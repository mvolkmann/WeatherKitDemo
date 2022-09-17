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

    // MARK: - Constants

    private let dateWidth = 95.0
    private let symbolWidth = 30.0
    private let temperatureWidth = 50.0
    private let windWidth = 65.0
    private let precipitationWidth = 45.0

    // MARK: - Properties

    private var attributionLogoURL: URL? {
        colorScheme == .light ?
            summary?.attributionLightLogoURL :
            summary?.attributionDarkLogoURL
    }

    private let dateFormatter = DateFormatter()

    private var formattedTemperature: String {
        guard let temperature = summary?.temperature else { return "" }
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

    private let weatherService = WeatherService.shared

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            VStack {
                Text("WeatherKit Demo")
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
                        Link(destination: summary.attributionPageURL) {
                            AsyncImage(
                                url: attributionLogoURL,
                                content: { image in image.resizable() },
                                placeholder: { ProgressView() }
                            )
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                        }
                    }
                    .foregroundColor(.primary)

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
                .frame(width: dateWidth)
            Image.symbol(symbolName: forecast.symbolName, size: 30)
                .frame(width: symbolWidth)
            Text(format(
                temperature: forecast.temperature.converted(to: .fahrenheit)
            ))
            .frame(width: temperatureWidth)
            Text(forecast.wind.speed.formatted())
                .frame(width: windWidth)
            Text(format(precipitation: forecast.precipitationAmount))
                .frame(width: precipitationWidth)
        }
    }

    private func format(precipitation: Measurement<UnitLength>) -> String {
        let converted = precipitation.converted(to: .inches)
        return String(format: "%.1f", converted.value) + converted.unit.symbol
    }

    private func format(temperature: Measurement<UnitTemperature>) -> String {
        String(format: "%.0f", temperature.value) + temperature.unit.symbol
    }
}
