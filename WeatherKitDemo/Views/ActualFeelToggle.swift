import SwiftUI

struct ActualFeelToggle: View {
    @AppStorage("showFeel") var showFeel = false
    @StateObject private var weatherVM = WeatherViewModel.shared

    var body: some View {
        Toggle2(
            off: "Actual",
            on: "Feels Like",
            isOn: $weatherVM.useFeel
        )
        .font(.callout)
        // Keep AppStorage in sync with setting in WeatherViewModel.
        .onChange(of: weatherVM.useFeel) { useFeel in
            showFeel = useFeel
        }
    }
}
