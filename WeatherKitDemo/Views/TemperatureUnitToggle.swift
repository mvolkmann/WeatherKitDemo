import SwiftUI

struct TemperatureUnitToggle: View {
    @AppStorage("showFahrenheit") private var showFahrenheit: Bool?
    @StateObject private var weatherVM = WeatherViewModel.shared

    var body: some View {
        Toggle2(
            off: "Celsius",
            on: "Fahrenheit",
            isOn: $weatherVM.useFahrenheit
        )
        // Keep AppStorage in sync with setting in WeatherViewModel.
        .onChange(of: weatherVM.useFahrenheit) { showFahrenheit = $0 }
    }
}
