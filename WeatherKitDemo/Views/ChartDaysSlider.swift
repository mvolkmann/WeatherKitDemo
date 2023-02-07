import SwiftUI
import WeatherKit

struct ChartDaysSlider: View {
    @AppStorage("showChartDays") private var showChartDays = WeatherService.days
    @State private var days = 0.0
    @StateObject private var weatherVM = WeatherViewModel.shared

    var body: some View {
        VStack(spacing: 0) {
            Text("chart-days \(weatherVM.chartDays)")
            Slider(
                value: $days,
                in: 1 ... 5,
                step: 1,
                label: { Text("Chart Days") }, // not rendered
                // The next two attributes must be closures that return the
                // same kind of view.  Image and Text are common choices.
                minimumValueLabel: { Text("1") },
                maximumValueLabel: { Text("\(WeatherService.days)") }
            )
            // Keep AppStorage in sync with setting in WeatherViewModel.
            .onChange(of: days) {
                weatherVM.chartDays = Int($0)
                showChartDays = Int($0)
            }
        }
        .onAppear {
            days = Double(weatherVM.chartDays)
        }
    }
}
