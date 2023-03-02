import CoreLocation
import CoreLocationUI // for LocationButton
import MapKit
import SwiftUI
import WeatherKit

struct CurrentScreen: View {
    // MARK: - State

    @AppStorage("likedLocations") private var likedLocations: String = ""

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(
        \.horizontalSizeClass
    ) var horizontalSizeClass: UserInterfaceSizeClass?

    @FocusState private var isTextFieldFocused: Bool

    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    let appInfo: AppInfo?

    init(appInfo: AppInfo?) {
        self.appInfo = appInfo
    }

    // MARK: - Properties

    private var attributionLogoURL: URL? {
        guard let summary = weatherVM.summary else { return nil }

        return colorScheme == .light ?
            summary.attributionLightLogoURL :
            summary.attributionDarkLogoURL
    }

    private var currentLocationButton: some View {
        LocationButton {
            if let placemark = locationVM.currentPlacemark {
                selectPlacemark(placemark)
            }
        }
        .cornerRadius(10)
        .foregroundColor(.white)
    }

    private var favoriteLocations: some View {
        List {
            ForEach(
                locationVM.likedLocations,
                id: \.self
            ) { location in
                Button(location) {
                    selectLocation(location)
                }
            }
            .onDelete { offsets in
                for offset in offsets {
                    let location = locationVM.likedLocations[offset]
                    locationVM.unlikeLocation(location)
                }

                // Persist in AppStorage.   We cannot use comma for
                // separator because some locations contain commas.
                likedLocations =
                    locationVM.likedLocations.joined(separator: "|")
            }
        }
        .listStyle(.plain)
    }

    private var formattedActual: String {
        formatTemperature(weatherVM.summary?.temperature)
    }

    private var formattedFeelsLike: String {
        formatTemperature(weatherVM.summary?.apparentTemperature)
    }

    private var isWide: Bool { horizontalSizeClass != .compact }

    private var matchedLocations: some View {
        List {
            ForEach(
                locationVM.searchLocations,
                id: \.self
            ) { location in
                Button(location) {
                    selectLocation(location)
                }
            }
        }
        .listStyle(.plain)
    }

    private var searchArea: some View {
        HStack(alignment: .center) {
            TextField("New Location", text: $locationVM.searchQuery)
                .disableAutocorrection(true)
                .focused($isTextFieldFocused)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(.background)
                )
                .foregroundColor(.primary)
            if isTextFieldFocused {
                Button(action: dismissKeyboard) {
                    Image(
                        systemName: "keyboard.chevron.compact.down"
                    )
                }
                .font(.title)
            }
        }
        .padding(.top, 10)
    }

    var body: some View {
        Template(parent: "current") {
            VStack {
                if let appInfo,
                   !appInfo.haveLatestVersion,
                   let url = URL(string: appInfo.appURL) {
                    Link("Update Available", destination: url)
                }

                if locationVM.searchLocations.isEmpty {
                    currentData()
                }

                if locationVM.authorized, !locationVM.usingCurrent {
                    currentLocationButton
                }

                searchArea

                HStack {
                    if !locationVM.searchQuery.isEmpty,
                       !locationVM.searchLocations.isEmpty {
                        VStack {
                            Text("Matched Locations").font(.headline)
                            matchedLocations
                        }
                    } else if !locationVM.likedLocations.isEmpty {
                        VStack {
                            Text("Favorite Locations").font(.headline)
                            favoriteLocations
                        }
                    }
                }

                Spacer()

                attributionLink()
            }
            .frame(maxWidth: isWide ? 350 : .infinity)
        }
    }

    // MARK: - Methods

    @ViewBuilder
    private func attributionLink() -> some View {
        AsyncImage(
            url: attributionLogoURL,
            content: { image in image.resizable() },
            placeholder: { ProgressView() }
        )
        .aspectRatio(contentMode: .fit)
        .opacity(0.3)
        .frame(height: 20)
    }

    // Cannot return different kinds of views from a computed property.
    @ViewBuilder
    private func currentData() -> some View {
        if let summary = weatherVM.summary {
            VStack {
                ZStack(alignment: .top) {
                    // Only display the weather condition symbol if
                    // the user has not selected a really large font size.
                    if dynamicTypeSize < .xxLarge {
                        Image.symbol(symbolName: summary.symbolName, size: 70)
                            .padding(.top, 28)
                    }
                    VStack {
                        LabeledContent("Condition", value: summary.condition)
                            .accessibilityIdentifier("condition-label")
                        LabeledContent("Temperature", value: formattedActual)
                            .accessibilityIdentifier("temperature-label")
                        LabeledContent("Feels Like", value: formattedFeelsLike)
                            .accessibilityIdentifier("feels-like-label")

                        let firstForecast = summary.hourlyForecast.first!
                        let humidity = firstForecast.humidity * 100
                        LabeledContent(
                            "Humidity",
                            value: "\(String(format: "%.0f", humidity))%"
                        )
                        .accessibilityIdentifier("humidity-label")
                        LabeledContent("Winds", value: summary.wind)
                            .accessibilityIdentifier("winds-label")

                        if let dayWeather = weatherVM.dayWeather {
                            sunriseSunset(dayWeather: dayWeather)
                        }
                    }
                }
            }
            .font(.headline)

            // Don't allow the text size to be larger than .xLarge.
            .dynamicTypeSize(...DynamicTypeSize.xLarge)

            .foregroundColor(.primary)
            .padding(.top)
        } else {
            EmptyView()
        }
    }

    private func formatTemperature(
        _ temperature: Measurement<UnitTemperature>?
    ) -> String {
        guard let temperature else { return "" }
        return String(format: "%.0f", temperature.converted) +
            weatherVM.temperatureUnitSymbol
    }

    private func selectLocation(_ address: String) {
        Task {
            do {
                let placemark = try await LocationService
                    .getPlacemark(from: address)
                locationVM.select(placemark: placemark)
                dismissKeyboard()
            } catch {
                Log.error("error getting placemark: \(error)")
            }
        }
    }

    private func selectPlacemark(_ placemark: CLPlacemark) {
        locationVM.select(placemark: placemark)
        dismissKeyboard()
    }

    private func sunriseSunset(dayWeather: DayWeather) -> some View {
        let offset = Date.current.timeZoneOffset
        return Group {
            if let sunrise = dayWeather.sun.sunrise {
                LabeledContent(
                    "Sunrise",
                    value: sunrise.hoursAfter(offset).time
                )
                .accessibilityIdentifier("sunrise-label")
            }
            if let sunset = dayWeather.sun.sunset {
                LabeledContent(
                    "Sunset",
                    value: sunset.hoursAfter(offset).time
                )
                .accessibilityIdentifier("sunset-label")
            }
        }
    }
}
