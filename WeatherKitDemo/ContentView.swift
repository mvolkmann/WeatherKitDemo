import CoreLocation
import SwiftUI
import WeatherKit

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var attributionPageURL: URL?
    @State private var attributionLogoURL: URL?
    @State private var condition = ""
    @State private var symbolName = ""
    @State private var temperature = ""
    @State private var wind = ""
    @State private var weather: Weather?

    @StateObject private var locationManager = LocationManager()

    let weatherService = WeatherService.shared

    @ViewBuilder // allows returning multiple kinds of views
    private var attributionLink: some View {
        if let attributionPageURL, let attributionLogoURL {
            Link(destination: attributionPageURL) {
                AsyncImage(
                    url: attributionLogoURL,
                    content: { image in image.resizable() },
                    placeholder: { ProgressView() }
                )
                .aspectRatio(contentMode: .fit)
                .frame(height: 20)
            }
        } else {
            ProgressView()
        }
    }

    var body: some View {
        VStack {
            Text("WeatherKitDemo").font(.largeTitle)
            if weather == nil {
                ProgressView()
            } else {
                Image(systemName: symbolName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                Text("Condition: \(condition)")
                Text("Temperature: \(temperature)")
                Text("Wind: \(wind)")
                attributionLink
            }
        }
        .padding()
        .task(id: locationManager.currentLocation) {
            do {
                if let location = locationManager.currentLocation {
                    print("location =", location)
                    // TODO: Can you get the associated city?
                    try await loadWeather(for: location)
                    await hourlyForecast(for: location)
                }

                let attribution = try await weatherService.attribution
                print("attribution =", attribution)
                attributionPageURL = attribution.legalPageURL
                attributionLogoURL = colorScheme == .light ? attribution
                    .combinedMarkLightURL : attribution.combinedMarkDarkURL
            } catch {
                print("ContentView.body: error =", error)
            }
        }
    }

    private func hourlyForecast(for location: CLLocation) async {
        Task.detached(priority: .userInitiated) {
            let forecast = try? await weatherService.weather(
                for: location,
                including: .hourly
            )
            print("forecast =", forecast)
        }
    }

    private func loadWeather(for location: CLLocation) async throws {
        weather = try await weatherService.weather(for: location)
        guard let weather else { return }
        print("daily forecast =", weather.dailyForecast)

        let current = weather.currentWeather
        condition = current.condition.description
        symbolName = current.symbolName
        temperature = current.temperature.formatted()

        let windDescription = current.wind.speed
        let windDirection = current.wind.compassDirection
        // let windDescription = current.wind.speed.convert(to: Unit("mi/hr"))
        wind = "\(windDescription) from the \(windDirection)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
