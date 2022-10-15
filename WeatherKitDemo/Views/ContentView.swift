import CoreLocation
import SwiftUI
import WeatherKit

struct ContentView: View {
    @State private var selectedTab: String = "summary"

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
        }

        // Run this closure again every time the location changes.
        .task(id: locationVM.location) {
            if let location = locationVM.location {
                do {
                    try await weatherVM.load(location: location)
                } catch {
                    print("error loading weather forecast:", error)
                }
            }
        }
    }
}
