import Charts
import SwiftUI

struct ChartScreen: View {
    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            VStack {
                Text("WeatherKit Demo")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                Text(
                    "Location: \(locationVM.city), \(locationVM.state)"
                )

                if let summary = weatherVM.summary {
                    Chart(summary.hourlyForecast) { forecast in
                        let date = PlottableValue.value("Date", forecast.date)
                        let temperature = PlottableValue.value(
                            "Temperature",
                            forecast.temperature.converted(to: .fahrenheit)
                                .value
                        )
                        LineMark(x: date, y: temperature)
                            .interpolationMethod(.catmullRom)
                        PointMark(x: date, y: temperature)
                        AreaMark(x: date, y: temperature)
                            .foregroundStyle(.yellow.opacity(0.2))
                    }
                } else {
                    Spacer()
                    Text("Waiting for weather forecast ...")
                    Spacer()
                }
            }
            .padding()
        }
    }
}
