import SwiftUI
import WeatherKit

struct CurrentScreen: View {
    // MARK: - State

    @Environment(\.colorScheme) private var colorScheme

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
            if let summary = weatherVM.summary {
                VStack {
                    Image.symbol(symbolName: summary.symbolName)
                    Text("Condition: \(summary.condition)")
                    Text("Temperature: \(formattedTemperature)")
                    // Text("Humidity: \(summary.)")
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

            // TODO: Add ability to enter a new location.
        }
    }
}
