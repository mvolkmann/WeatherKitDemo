import SwiftUI

struct HeatMapToggle: View {
    @AppStorage("heatMapDaysOnTop") private var heatMapDaysOnTop = false
    @StateObject private var weatherVM = WeatherViewModel.shared

    var body: some View {
        VStack(spacing: 0) {
            Text("Heat Map Rotation")
            Toggle2(
                off: "Days on Left",
                on: "Days on Top",
                isOn: $heatMapDaysOnTop
            )
        }
    }
}
