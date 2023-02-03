import CoreLocation
import SwiftUI
import WeatherKit

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var isSettingsPresented = false
    @State private var selectedTab: String = "current"

    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    init() {
        customizeNavBar()
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                CurrentScreen()
                    .tabItem { Label("Current", systemImage: "clock") }
                    .tag("current")
                ForecastScreen()
                    .tabItem { Label("Forecast", systemImage: "tablecells") }
                    .tag("forecast")
                ChartScreen()
                    .tabItem { Label("Chart", systemImage: "chart.xyaxis.line")
                    }
                    .tag("chart")
                HeatMapScreen()
                    // HeatMap2Screen()
                    .tabItem {
                        Label("Heat Map", systemImage: "thermometer.sun")
                    }
                    .tag("heatmap")
            }
            .navigationTitle("Feather Weather")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: refreshForecast) {
                    Image(systemName: "arrow.clockwise")
                },
                trailing: Button(action: { isSettingsPresented = true }) {
                    Image(systemName: "gear")
                }
            )
        }

        .sheet(isPresented: $isSettingsPresented) {
            Settings()
                // Need at least this height for iPhone SE.
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
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

    private func customizeNavBar() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 30, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = navigationAppearance
    }

    private func refreshForecast() {
        guard let location = locationVM.selectedPlacemark?.location
        else { return }

        Task {
            try? await weatherVM.load(
                location: location,
                colorScheme: colorScheme
            )
        }
    }
}
