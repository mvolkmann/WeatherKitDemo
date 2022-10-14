import CoreLocation
import SwiftUI
import WeatherKit

struct ContentView: View {
    // MARK: - State

    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedTab: String = "chart"
    @State private var summary: WeatherSummary?

    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    // MARK: - Properties

    private let weatherService = WeatherService.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            SummaryScreen()
                .tabItem { Label("Summary", systemImage: "tablecells") }
                .tag("summary")
            ChartScreen()
                .tabItem { Label("Chart", systemImage: "chart.xyaxis.line") }
                .tag("chart")
        }

        // Run this closure again after the location is determined.
        .task(id: locationVM.location) {
            if let location = locationVM.location {
                print("location =", location)
                do {
                    weatherVM.summary = try await weatherService.summary(
                        for: location,
                        colorScheme: colorScheme
                    )
                    // print("summary =", weatherVM.summary)
                } catch {
                    print("ContentView error:", error)
                }
            }
        }
    }
}
