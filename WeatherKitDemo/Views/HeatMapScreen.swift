import Charts
import SwiftUI
import WeatherKit

struct HeatMapScreen: View {
    private static let gradientColors: [Color] =
        [.blue, .green, .yellow, .orange, .red]

    private let vm = WeatherViewModel.shared

    var body: some View {
        Template {
            if let hourlyForecast = vm.summary?.hourlyForecast {
                heatMap(hourlyForecast: hourlyForecast)
            } else {
                Text("Forecast data is not available.")
            }
        }
    }

    // MARK: - Methods

    private func heatMap(hourlyForecast: [HourWeather]) -> some View {
        Chart {
            ForEach(hourlyForecast.indices, id: \.self) { index in
                let forecast = hourlyForecast[index]
                mark(forecast: forecast)
            }
        }

        .padding(.leading, 60) // leaves room for y-axis labels
        .padding(.trailing, 20)

        .chartForegroundStyleScale(
            range: Gradient(colors: Self.gradientColors)
        )

        // .chartYAxis(.hidden)

        // This changes the rectangle heights so they
        // no longer cover the entire plot area.
        /*
          .chartYAxis {
          AxisMarks { _ in
          AxisGridLine()
          AxisTick()
          // Oddly .trailing causes the labels to be
          // displayed on the leading edge of the chart.
          AxisValueLabel(anchor: .topTrailing)
          }
          }

         .chartYAxis {
             AxisMarks(values: .automatic(
                 desiredCount: vm.statistics.count,
                 roundLowerBound: false,
                 roundUpperBound: false
             )) { _ in
                 AxisGridLine()
                 AxisTick()
                 AxisValueLabel(centered: true)
             }
         }
          */

        .frame(height: 500)
    }

    private func mark(forecast: HourWeather) -> some ChartContent {
        let date = forecast.date
        let fahrenheit = forecast.temperature.converted(to: .fahrenheit).value

        return Plot {
            RectangleMark(
                // This approach loses the x-axis labels.
                /*
                 xStart: PlottableValue.value("xStart", 0),
                 xEnd: PlottableValue.value("xEnd", 1),
                 yStart: PlottableValue.value("yStart", index),
                 yEnd: PlottableValue.value("yEnd", index + 1)
                 */

                x: .value("Time", date.h),
                y: .value("Date", date.md),
                width: .ratio(1),
                height: .ratio(1)
            )
            .foregroundStyle(by: .value("Temperature", fahrenheit))
        }
        .accessibilityLabel("\(date.md) \(date.h)")
        .accessibilityValue("\(fahrenheit)")
        .accessibilityHidden(false)
    }
}
