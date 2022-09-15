import SwiftUI
import WeatherKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    let weatherService = WeatherService.shared
    @State private var weather: Weather?

    private var temperature: String {
        guard let weather else { return "" }
        let current = weather.currentWeather
        print("current =", current)
        return current.temperature.formatted()
    }

    var body: some View {
        VStack {
            Text("WeatherKitDemo").font(.headline)
            Text("Temperature: \(temperature)")
        }
        .padding()
        .task(id: locationManager.currentLocation) {
            do {
                if let location = locationManager.currentLocation {
                    print("location =", location)
                    weather = try await weatherService.weather(for: location)
                }
            } catch {
                print("ContentView.body: error =", error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
