import SwiftUI

struct ColorToggle: View {
    @AppStorage("showAbsoluteColors") private var showAbsoluteColors = false
    @AppStorage("showFahrenheit") private var showFahrenheit = false
    @StateObject private var weatherVM = WeatherViewModel.shared

    private var helpText: some View {
        let low = showFahrenheit ? "0℉" : "-17.8℃"
        let high = showFahrenheit ? "100℉" : "37.8℃"
        return showAbsoluteColors ?
            Text("absolute-help \(low) \(high)") :
            Text("relative-help")
    }

    var body: some View {
        VStack {
            Toggle2(
                off: "Relative Colors",
                on: "Absolute Colors",
                isOn: $showAbsoluteColors
            )

            helpText
                // .font(.footnote)
                .font(.system(size: 14))
        }
    }
}
