import CoreLocation
import SwiftUI
import WeatherKit

struct CurrentScreen: View {
    // MARK: - State

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isTextFieldFocused: Bool
    @State private var addressString = ""
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

    var body: some View {
        Template {
            VStack {
                if let summary = weatherVM.summary {
                    VStack {
                        Image.symbol(symbolName: summary.symbolName)
                        Text("Condition: \(summary.condition)")
                        Text("Temperature: \(formattedTemperature)")

                        let firstForecast = summary.hourlyForecast.first!
                        let humidity = firstForecast.humidity * 100
                        Text("Humidity: \(String(format: "%.0f", humidity))%")

                        Text("Winds \(summary.wind)")

                        Link(destination: summary.attributionPageURL) {
                            AsyncImage(
                                url: attributionLogoURL,
                                content: { image in image.resizable() },
                                placeholder: { ProgressView() }
                            )
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                        }
                    }
                    .foregroundColor(.primary)
                }

                HStack(alignment: .center) {
                    TextField("Location", text: $addressString)
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
                .padding(.top)

                if !locationVM.usingCurrent {
                    Button("Current Location") {
                        locationVM.resetPlacemark()
                    }
                    .buttonStyle(.borderedProminent)
                }

                ForEach(placemarks, id: \.self) { placemark in
                    if let city = placemark.locality {
                        let state = placemark.administrativeArea ?? "unknown"
                        Button("\(city), \(state)") {
                            selectPlacemark(placemark)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }

            .onChange(of: addressString) { _ in
                Task {
                    placemarks = try await LocationViewModel.getPlacemarks(
                        addressString: addressString
                    )
                }
            }
        }
    }

    private func selectPlacemark(_ placemark: CLPlacemark) {
        locationVM.selectedPlacemark = placemark
        addressString = ""
        placemarks = []
        dismissKeyboard()
    }
}
