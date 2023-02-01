import CoreLocation
import CoreLocationUI // for LocationButton
import MapKit
import SwiftUI
import WeatherKit

struct CurrentScreen: View {
    // MARK: - State

    @AppStorage("likedLocations") var likedLocations: String = ""

    @Environment(\.colorScheme) private var colorScheme
    @Environment(
        \.horizontalSizeClass
    ) var horizontalSizeClass: UserInterfaceSizeClass?

    @FocusState private var isTextFieldFocused: Bool

    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

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
        guard let temp = weatherVM.summary?.temperature else { return "" }
        return String(format: "%.0f", temp.converted) +
            weatherVM.temperatureUnitSymbol
    }

    private var formattedFeelsLike: String {
        guard let forecast = weatherVM.summary?.hourlyForecast
        else { return "" }
        guard let temp = forecast.first?.apparentTemperature else { return "" }
        return String(format: "%.0f", temp.converted) +
            weatherVM.temperatureUnitSymbol
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
        Template {
            VStack {
                if locationVM.searchLocations.isEmpty {
                    currentData()
                }

                if locationVM.authorized && !locationVM.usingCurrent {
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

    @ViewBuilder
    private func attributionLink() -> some View {
        if let summary = weatherVM.summary {
            Link(destination: summary.attributionPageURL) {
                AsyncImage(
                    url: attributionLogoURL,
                    content: { image in image.resizable() },
                    placeholder: { ProgressView() }
                )
                .aspectRatio(contentMode: .fit)
                .opacity(0.3)
                .frame(height: 20)
            }
        } else {
            EmptyView()
        }
    }

    // Cannot return different kinds of views from a computed property.
    @ViewBuilder
    private func currentData() -> some View {
        if let summary = weatherVM.summary {
            VStack {
                ZStack(alignment: .top) {
                    Image.symbol(symbolName: summary.symbolName, size: 70)
                        .padding(.top, 28)
                    VStack {
                        LabeledContent("Condition", value: summary.condition)
                        LabeledContent("Temperature", value: formattedActual)
                        LabeledContent("Feels Like", value: formattedFeelsLike)

                        let firstForecast = summary.hourlyForecast.first!
                        let humidity = firstForecast.humidity * 100
                        LabeledContent(
                            "Humidity",
                            value: "\(String(format: "%.0f", humidity))%"
                        )
                        LabeledContent("Winds", value: summary.wind)
                    }
                }
            }
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.top)
        } else {
            EmptyView()
        }
    }

    private func selectLocation(_ location: String) {
        Task {
            do {
                let placemark = try await LocationService
                    .getPlacemark(from: location)
                locationVM.select(placemark: placemark)
                dismissKeyboard()
            } catch {
                print("CurrentScreen.selectLocation error:", error)
            }
        }
    }

    private func selectPlacemark(_ placemark: CLPlacemark) {
        locationVM.select(placemark: placemark)
        dismissKeyboard()
    }
}
