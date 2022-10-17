import CoreLocation
import SwiftUI
import WeatherKit

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedTab: String = "current"

    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            CurrentScreen()
                .tabItem { Label("Current", systemImage: "clock") }
                .tag("current")
            ForecastScreen()
                .tabItem { Label("Forecast", systemImage: "tablecells") }
                .tag("forecast")
            ChartScreen()
                .tabItem { Label("Chart", systemImage: "chart.xyaxis.line") }
                .tag("chart")
            HeatMapScreen()
                .tabItem { Label("Heat Map", systemImage: "thermometer.sun") }
                .tag("heatmap")
        }

        // Run this closure again every time the selected placemark changes.
        .task(id: locationVM.selectedPlacemark, priority: .background) {
            if let location = locationVM.selectedPlacemark?.location {
                do {
                    try await weatherVM.load(
                        location: location,
                        colorScheme: colorScheme
                    )
                } catch {
                    print("error loading weather forecast:", error)
                }
            }
        }
    }
}
