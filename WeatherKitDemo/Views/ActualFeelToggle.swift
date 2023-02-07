import SwiftUI

struct ActualFeelToggle: View {
    @AppStorage("showFeel") private var showFeel = false
    @StateObject private var weatherVM = WeatherViewModel.shared

    var body: some View {
        Toggle2(
            off: "Actual Temperature",
            on: "Feels Like Temperature",
            isOn: $weatherVM.useFeel
        )
        // Keep AppStorage in sync with setting in WeatherViewModel.
        .onChange(of: weatherVM.useFeel) { showFeel = $0 }
    }
}
