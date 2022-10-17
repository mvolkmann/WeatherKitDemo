import CoreLocation
import CoreLocationUI // for LocationButton
import MapKit
import SwiftUI
import WeatherKit

struct CurrentScreen: View {
    // MARK: - State

    @Environment(\.colorScheme) private var colorScheme
    @Environment(
        \.verticalSizeClass
    ) var verticalSizeClass: UserInterfaceSizeClass?

    @FocusState private var isTextFieldFocused: Bool

    @State private var placemarks: [CLPlacemark] = []

    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    // MARK: - Properties

    private var attributionLogoURL: URL? {
        guard let summary = weatherVM.summary else { return nil }

        return colorScheme == .light ?
            summary.attributionLightLogoURL :
            summary.attributionDarkLogoURL
    }

    private var formattedTemperature: String {
        guard let temp = weatherVM.summary?.temperature else { return "" }
        // return temp.description // too many decimal places
        return String(format: "%.0f", temp.value) + temp.unit.symbol
    }

    private var width: CGFloat {
        verticalSizeClass == .compact ? 350 : .infinity
    }

    var body: some View {
        Template {
            VStack {
                if locationVM.searchLocations.isEmpty {
                    currentData()
                }

                HStack(alignment: .center) {
                    TextField("Location", text: $locationVM.searchQuery)
                        .focused($isTextFieldFocused)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        )
                    if isTextFieldFocused {
                        Button(action: dismissKeyboard) {
                            Image(
                                systemName: "keyboard.chevron.compact.down"
                            )
                        }
                        .font(.title)
                    }
                }
                .frame(maxWidth: width)
                .padding(.top)

                if !locationVM.usingCurrent {
                    LocationButton {
                        if let placemark = locationVM.currentPlacemark {
                            selectPlacemark(placemark)
                        }
                    }
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                if !locationVM.searchLocations.isEmpty {
                    List {
                        ForEach(locationVM.searchLocations, id: \.self) { location in
                            Button(location) {
                                // selectPlacemark(placemark)
                                selectLocation(location)
                            }
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()

                attributionLink()
            }
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
                Image.symbol(symbolName: summary.symbolName)
                Text("Condition: \(summary.condition)")
                Text("Temperature: \(formattedTemperature)")

                let firstForecast = summary.hourlyForecast.first!
                let humidity = firstForecast.humidity * 100
                Text("Humidity: \(String(format: "%.0f", humidity))%")

                Text("Winds \(summary.wind)")
            }
            .foregroundColor(.primary)
        } else {
            EmptyView()
        }
    }

    private func selectLocation(_ location: String) {
        Task {
            do {
                let placemark = try await LocationService.getPlacemark(from: location)
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
