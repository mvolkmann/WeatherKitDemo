import Charts
import SwiftUI
import WeatherKit

struct HeatMapScreen: View {
    @State private var hourlyForecast: [HourWeather] = []

    private static let gradientColors: [Color] =
        [.blue, .green, .yellow, .orange, .red]
    // The above looks better than using [.blue, .yellow, .red].

    private let weatherVM = WeatherViewModel.shared

    var body: some View {
        Template {
            Text("Heat Map").font(.title2)
            if !hourlyForecast.isEmpty {
                HStack(alignment: .top, spacing: 0) {
                    VStack {
                        dayLabel("Tue")
                        dayLabel("Wed")
                        dayLabel("Thu")
                        dayLabel("Fri")
                    }
                    .padding(.top, 7)

                    ScrollView(.horizontal) {
                        heatMap(hourlyForecast: hourlyForecast)
                    }
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

    private func dayLabel(_ day: String) -> some View {
        Text(day)
            .rotationEffect(Angle.degrees(-90))
            .frame(height: 47)
    }

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

    private func heatMap(hourlyForecast: [HourWeather]) -> some View {
        Chart {
            let firstDate = hourlyForecast.first?.date ?? Date()
            let day = firstDate.dayOfWeek
            let firstHour = firstDate.hour
            ForEach(0 ..< firstHour, id: \.self) { hour in
                emptyMark(day: day, hour: hour)
            }

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

        .chartYAxis(.hidden)
        /*
         // I can't get the labels to appear to the left of each row.
         // They display above each row.
         .chartYAxis {
             AxisMarks() // displays day of week abbreviations
         }
         */

        .frame(width: 800, height: 300)
    }

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
            .foregroundStyle(by: .value("Temperature", fahrenheit))
            .annotation(position: .overlay) {
                // Text("\(date.dayOfWeek)")
                Text("\(String(format: "%.0f", fahrenheit))℉")
                    .rotationEffect(.degrees(-90))
                    .font(.body)
                    .frame(width: 50)
            }
        }
        .accessibilityLabel("\(date.md) \(date.h)")
        .accessibilityValue("\(fahrenheit)")
        .accessibilityHidden(false)
    }
}
