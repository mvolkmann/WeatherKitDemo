import CoreLocation
import StoreKit
import SwiftUI
import WeatherKit

struct ContentView: View {
    @AppStorage("chartVisits") private var chartVisits = 0
    @AppStorage("currentVisits") private var currentVisits = 0
    @AppStorage("forecastVisits") private var forecastVisits = 0
    @AppStorage("heatMapVisits") private var heatMapVisits = 0
    @AppStorage("settingsVisits") private var settingsVisits = 0

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) var openURL

    // This must be called from inside a view.
    @Environment(\.requestReview) var requestReview

    @State private var appInfo: AppInfo?
    @State private var isInfoPresented = false
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
                    .tabItem {
                        Label("Heat Map", systemImage: "thermometer.sun")
                    }
                    .tag("heatmap")
            }
            .navigationTitle("Feather Weather")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedTab) { _ in
                switch selectedTab {
                case "chart": chartVisits += 1
                case "current": currentVisits += 1
                case "forecast": forecastVisits += 1
                case "heatmap": heatMapVisits += 1
                default: break
                }

                appReview()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Using HStack to reduce space between toolbar items.
                    HStack(spacing: 0) {
                        Button(action: { isInfoPresented = true }) {
                            Image(systemName: "info.circle")
                        }
                        if let appInfo {
                            Link(destination: URL(
                                string: appInfo
                                    .supportURL
                            )!) {
                                Image(systemName: "questionmark.circle")
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Using HStack to reduce space between toolbar items.
                    HStack(spacing: 0) {
                        Button(action: refreshForecast) {
                            Image(systemName: "arrow.clockwise")
                        }
                        Button(action: {
                            settingsVisits += 1
                            isSettingsPresented = true
                            appReview()
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
        }

        .sheet(isPresented: $isInfoPresented) {
            Info(appInfo: appInfo!)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
        }

        .sheet(isPresented: $isSettingsPresented) {
            Settings()
                // Need at least this height for iPhone SE.
                .presentationDetents([.height(430)])
                .presentationDragIndicator(.visible)
        }

        // Run this closure again every time the selected coordinate changes.
        // We can't just check for changes in `selectedPlacement`
        // or its `location` because CLLocation has a timestamp property
        // that provides the time at which the location was determined and
        // we don't want to load weather data again
        // if only the timestamp changed.
        .task(
            id: locationVM.selectedPlacemark?.location?.coordinate,
            priority: .background
        ) {
            guard let location = locationVM.selectedPlacemark?.location else {
                return
            }

            do {
                try await weatherVM.load(
                    location: location,
                    colorScheme: colorScheme
                )
            } catch {
                // TODO: Why do we sometimes get a "cancelled" error?
                if error.localizedDescription != "cancelled" {
                    Log.error("error loading forecast: \(error)")
                }
            }
        }

        .task {
            do {
                appInfo = try await AppInfo.create()
            } catch {
                Log.error("error getting AppInfo: \(error)")
            }
        }
    }

    private func appReview() {
        guard AppReview.shared.shouldRequest else { return }

        Task {
            // Wait 3 seconds before requesting an app review.
            try await Task.sleep(
                until: .now + .seconds(3),
                clock: .suspending
            )
            requestReview()
        }
    }

    private func customizeNavBar() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            // When the font size is 30 or more, this causes the error
            // "[LayoutConstraints] Unable to simultaneously
            // satisfy constraints", but it still works.
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = navigationAppearance
    }

    private func refreshForecast() {
        guard let location = locationVM.selectedPlacemark?.location else {
            return
        }

        Task {
            try? await weatherVM.load(
                location: location,
                colorScheme: colorScheme
            )
        }
    }
}
