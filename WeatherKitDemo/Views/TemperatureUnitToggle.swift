import SwiftUI

struct TemperatureUnitToggle: View {
    @AppStorage("showFahrenheit") private var showFahrenheit = false
    @StateObject private var weatherVM = WeatherViewModel.shared

    var body: some View {
        Toggle2(
            off: "Celsius",
            on: "Fahrenheit",
            isOn: $showFahrenheit
        )
    }
}
