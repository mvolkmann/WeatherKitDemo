import CoreLocation
import SwiftUI
import WeatherKit

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) var openURL

    @State private var appInfo: AppInfo?
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
                CurrentScreen(appInfo: appInfo)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let appInfo {
                        Link(destination: URL(string: appInfo.supportURL)!) {
                            Image(systemName: "questionmark.circle")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshForecast) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isSettingsPresented = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
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

        .task {
            do {
                appInfo = try await AppInfo.create()
            } catch {
                print("Error getting AppInfo:", error)
            }
        }
    }

    private func customizeNavBar() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            // When the font size is 30 or more, this causes the error
            // "[LayoutConstraints] Unable to simultaneously
            // satisfy constraints", but it still works.
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
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
