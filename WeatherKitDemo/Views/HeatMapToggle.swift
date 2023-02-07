import SwiftUI

struct HeatMapToggle: View {
    @AppStorage("showHeatMapDaysOnTop") private var showHeatMapDaysOnTop: Bool?
    @StateObject private var weatherVM = WeatherViewModel.shared

    var body: some View {
        VStack(spacing: 0) {
            Text("Heat Map Rotation")
            Toggle2(
                off: "Days on Left",
                on: "Days on Top",
                isOn: $weatherVM.heatMapDaysOnTop
            )
            // Keep AppStorage in sync with setting in WeatherViewModel.
            .onChange(of: weatherVM.heatMapDaysOnTop) {
                showHeatMapDaysOnTop = $0
            }
        }
    }
}
