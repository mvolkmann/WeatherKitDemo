import Charts
import SwiftUI
import WeatherKit

struct HeatMapScreen: View {
    // MARK: - State

    @State private var hourlyForecast: [HourWeather] = []

    // MARK: - Constants

    private static let daysOfWeek =
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    private static let gradientColors: [Color] =
        [.blue, .green, .yellow, .orange, .red]
    // The above looks better than using [.blue, .yellow, .red].

    // MARK: - Variables

    private var dayLabels: some View {
        VStack(spacing: 21) {
            let startIndex = Date().dayOfWeekNumber - 1
            let range =
                startIndex ..< startIndex + WeatherService.days
            ForEach(range, id: \.self) { index in
                dayLabel(Self.daysOfWeek[index % 7])
            }
        }
        .padding(.top, 11)
    }

    private let weatherVM = WeatherViewModel.shared

    var body: some View {
        Template {
            if !hourlyForecast.isEmpty {
                HStack(alignment: .top, spacing: 0) {
                    dayLabels

                    ScrollView(.horizontal) {
                        heatMap(hourlyForecast: hourlyForecast)
                            // Prevent scrollbar from overlapping legend.
                            .padding(.bottom, 10)
                    }
                }
            } else {
                Text("Forecast data is not available.")
            }
        }
        // Run this closure again every time the selected placemark changes.
        .task(id: weatherVM.summary) {
            if let summary = weatherVM.summary {
                hourlyForecast = summary.hourlyForecast
            }
        }
    }

    // MARK: - Methods

    private func dayLabel(_ day: String) -> some View {
        Text(day)
            .rotationEffect(Angle.degrees(-90))
            .frame(height: 55)
    }

    /*
     private func emptyMark(day: String, hour: Int) -> some ChartContent {
         return Plot {
             RectangleMark(
                 // Why do String values work, but Int values do not?
                 x: .value("Time", "\(hour)"),
                 y: .value("Day", day),
                 width: .ratio(1),
                 height: .ratio(1)
             )
             .foregroundStyle(.clear)
         }
     }
     */

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

        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic) { axisValue in
                AxisTick()
                AxisValueLabel(centered: true) {
                    let index = axisValue.index
                    let mod = index % 12
                    let hour = mod == 0 ? 12 : mod
                    Text("\(hour)\n\(index < 12 ? "AM" : "PM")")
                        .multilineTextAlignment(.center)
                }
            }
        }

        // I can't get the y-axis labels to appear to the left of each row.
        // They display above each row.
        .chartYAxis(.hidden)

        .frame(width: 800, height: Double(WeatherService.days * 90))
    }

    // This creates an individual cell in the heat map.
    private func mark(forecast: HourWeather) -> some ChartContent {
        let date = forecast.date
        let fahrenheit = forecast.temperature.converted(to: .fahrenheit).value

        return Plot {
            RectangleMark(
                // Why do String values work, but Int values do not?
                x: .value("Time", "\(date.hour)"),
                y: .value("Day", date.dayOfWeek),
                width: .ratio(1),
                height: .ratio(1)
            )
            // Choose a cell color based on the temperature.
            .foregroundStyle(by: .value("Temperature", fahrenheit))
            // Display the temperature on top of the cell.
            .annotation(position: .overlay) {
                Text("\(String(format: "%.0f", fahrenheit))℉")
                    .rotationEffect(.degrees(-90))
                    .font(.body)
                    .frame(width: 55)
            }
        }
        .accessibilityLabel("\(date.md) \(date.h)")
        .accessibilityValue("\(fahrenheit)")
        .accessibilityHidden(false)
    }
}
