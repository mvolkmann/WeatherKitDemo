import Charts
import SwiftUI
import WeatherKit

struct HeatMapScreen: View {
    @State private var hourlyForecast: [HourWeather] = []

    private static let gradientColors: [Color] =
        [.blue, .green, .yellow, .orange, .red]

    private let weatherVM = WeatherViewModel.shared

    var body: some View {
        Template {
            Text("Heat Map").font(.title2)
            if !hourlyForecast.isEmpty {
                ScrollView(.horizontal) {
                    heatMap(hourlyForecast: hourlyForecast)
                }
            } else {
                Text("Forecast data is not available.")
            }
        }
        // Run this closure again every time the selected placemark changes.
        .task(id: weatherVM.summary) {
            // .onChange(of: weatherVM.summary) { summary in
            if let summary = weatherVM.summary {
                hourlyForecast = summary.hourlyForecast
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

        .chartForegroundStyleScale(
            range: Gradient(colors: Self.gradientColors)
        )

        .chartXAxis(.hidden)
        .chartYAxis(.hidden)

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

        .frame(width: 800, height: 500)
    }

    private func mark(forecast: HourWeather) -> some ChartContent {
        let date = forecast.date
        let fahrenheit = forecast.temperature.converted(to: .fahrenheit).value

        return Plot {
            let day = date.dayOfWeek
            let hour = date.h
            RectangleMark(
                // This approach loses the x-axis labels.
                /*
                 xStart: PlottableValue.value("xStart", 0),
                 xEnd: PlottableValue.value("xEnd", 1),
                 yStart: PlottableValue.value("yStart", index),
                 yEnd: PlottableValue.value("yEnd", index + 1)
                 */

                x: .value("Time", hour),
                y: .value("Day", day),
                width: .ratio(1),
                height: .ratio(1)
            )
            .foregroundStyle(by: .value("Temperature", fahrenheit))
            .annotation(position: .overlay) {
                // let foo = print("\(day) \(hour)")
                Text("\(day) \(hour)")
                    .rotationEffect(.degrees(-90))
                    .font(.body)
                    .frame(width: 100)
            }
        }
        .accessibilityLabel("\(date.md) \(date.h)")
        .accessibilityValue("\(fahrenheit)")
        .accessibilityHidden(false)
    }
}
