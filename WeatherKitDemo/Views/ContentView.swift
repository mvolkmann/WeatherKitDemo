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

    @EnvironmentObject private var errorVM: ErrorViewModel

    // This must be called from inside a view.

    #if os(iOS)
        @Environment(\.requestReview) var requestReview
    #endif

    @State private var appInfo: AppInfo?
    @State private var isInfoPresented = false
    @State private var isSettingsPresented = false
    @State private var selectedTab: String = "current"

    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    init() {
        customizeNavBar()
    }

    private func appReview() {
        #if os(iOS)
            guard AppReview.shared.shouldRequest else { return }

            Task {
                // Wait 3 seconds before requesting an app review.
                try await Task.sleep(
                    until: .now + .seconds(3),
                    clock: .suspending
                )
                requestReview()
            }
        #endif
    }

    private func coordinateChanged() async {
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
                errorVM.alert(
                    error: error,
                    message: "Failed to load forecast."
                )
            }
        }
    }

    private func customizeNavBar() {
        #if os(iOS)
            let navigationAppearance = UINavigationBarAppearance()
            navigationAppearance.titleTextAttributes = [
                .foregroundColor: UIColor.systemBlue,
                // When the font size is 30 or more, this causes the error
                // "[LayoutConstraints] Unable to simultaneously
                // satisfy constraints", but it still works.
                .font: UIFont.systemFont(ofSize: 24, weight: .bold)
            ]
            UINavigationBar.appearance()
                .standardAppearance = navigationAppearance
        #endif
    }

    private var navBarLeading: some View {
        // Using HStack to reduce space between toolbar items.
        HStack(spacing: 0) {
            Button(action: { isInfoPresented = true }) {
                Image(systemName: "info.circle")
            }
            .accessibilityIdentifier("info-button")
            if let appInfo {
                Link(destination: URL(
                    string: appInfo.supportURL
                )!) {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
    }

    private var navBarTrailing: some View {
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
            .accessibilityIdentifier("settings-button")
        }
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

    private func tabSelected() {
        switch selectedTab {
        case "chart": chartVisits += 1
        case "current": currentVisits += 1
        case "forecast": forecastVisits += 1
        case "heatmap": heatMapVisits += 1
        default: break
        }

        appReview()
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                CurrentScreen(appInfo: appInfo)
                    .tabItem {
                        Label("Current", systemImage: "clock")
                            .accessibilityIdentifier("current-tab")
                    }
                    .tag("current")
                ForecastScreen()
                    .tabItem {
                        Label("Forecast", systemImage: "tablecells")
                            .accessibilityIdentifier("forecast-tab")
                    }
                    .tag("forecast")
                ChartScreen()
                    .tabItem {
                        Label("Chart", systemImage: "chart.xyaxis.line")
                            .accessibilityIdentifier("chart-tab")
                    }
                    .tag("chart")
                HeatMapScreen()
                    .tabItem {
                        Label("Heat Map", systemImage: "thermometer.sun")
                            .accessibilityIdentifier("heat-map-tab")
                    }
                    .tag("heatmap")
            }
            .navigationTitle("Feather Weather")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .onChange(of: selectedTab) { _ in tabSelected() }
            #if os(iOS)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        navBarLeading
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        navBarTrailing
                    }
                }
            #endif
        }

        .alert(
            "Error",
            isPresented: $errorVM.errorOccurred,
            actions: {}, // no custom buttons
            message: { errorVM.text }
        )

        .sheet(isPresented: $isInfoPresented) {
            Info(appInfo: appInfo)
                .presentationDetents([.height(410)])
                .presentationDragIndicator(.visible)
        }

        .sheet(isPresented: $isSettingsPresented) {
            Settings()
                // Need at least this height for iPhone SE.
                .presentationDetents([.height(470)])
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
            await coordinateChanged()
        }

        .task {
            do {
                appInfo = try await AppInfo.create()
            } catch {
                errorVM.alert(
                    error: error,
                    message: "Failed to get AppInfo."
                )
            }
        }
    }
}
