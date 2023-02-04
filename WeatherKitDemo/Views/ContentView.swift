import CoreLocation
import SwiftUI
import WeatherKit

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) var openURL

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

        .task {
            let haveLatest = await haveLatestVersion()
            if !haveLatest {
                print("You do not have the latest version!")
                let urlPrefix = "https://apps.apple.com/us/app/"
                let appName = "feather-weather-forecasts"
                let appID = "1667050253"
                let appURL = "\(urlPrefix)\(appName)/id\(appID)"
                print("appURL =", appURL)
                if let url = URL(string: appURL) { openURL(url) }
                // To let the user tap a button to open the App Store ...
                // Link(destination: url) {
                //     Text("Get latest version")
                // }
            }
        }
    }

    private func haveLatestVersion() async -> Bool {
        let urlPrefix = "https://itunes.apple.com/lookup?bundleId="
        guard let info = Bundle.main.infoDictionary,
              let installedVersion =
              info["CFBundleShortVersionString"] as? String,
              let identifier = info["CFBundleIdentifier"] as? String,
              let url = URL(string: "\(urlPrefix)\(identifier)")
        else {
            return true // can't determine
        }

        print("identifier =", identifier)
        print("url =", url)

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            guard let json = try JSONSerialization.jsonObject(
                with: data,
                options: [.allowFragments]
            ) as? [String: Any] else {
                return true // can't determine
            }

            guard let results = (json["results"] as? [Any])?
                .first as? [String: Any] else {
                return true // can't determine
            }

            guard let storeVersion = results["version"] as? String else {
                return true // can't determine
            }

            print("installed version =", installedVersion)
            print("store version =", storeVersion)
            return installedVersion == storeVersion
        } catch {
            return true // can't determine
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
