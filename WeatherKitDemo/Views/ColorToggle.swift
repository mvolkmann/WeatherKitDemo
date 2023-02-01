import SwiftUI

struct ColorToggle: View {
    @AppStorage("showAbsoluteColors") var showAbsoluteColors = false
    @StateObject private var weatherVM = WeatherViewModel.shared

    private var helpText: some View {
        let low = weatherVM.useFahrenheit ? "0℉" : "-17.8℃"
        let high = weatherVM.useFahrenheit ? "100℉" : "37.8℃"
        return weatherVM.useAbsoluteColors ?
            Text("absolute-help \(low) \(high)") :
            Text("relative-help")
    }

    var body: some View {
        VStack {
            Toggle2(
                off: "Relative Colors",
                on: "Absolute Colors",
                isOn: $weatherVM.useAbsoluteColors
            )
            // Keep AppStorage in sync with setting in WeatherViewModel.
            .onChange(
                of: weatherVM.useAbsoluteColors
            ) { useAbsoluteColors in
                showAbsoluteColors = useAbsoluteColors
            }

            helpText
                // .font(.footnote)
                .font(.system(size: 14))
        }
    }
}
