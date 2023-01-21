import Charts
import SwiftUI
import WeatherKit

// Red is 0% through the gradient and is where we want to start.
// Blue is 70% through the gradient and is where we want to stop.
private let redPercent = 0.0
private let bluePercent = 0.65

private let absoluteHelp = """
In absolute move, \
blue represents 0℉" or less and \
red represents 100℉" or more.
"""

private let relativeHelp = """
In relative mode, \
blue represents the lowest temperature over the next five days and \
red represents the highest temperature over the next five days.
"""

struct HeatMapScreen: View {
    // MARK: - State

    @State private var hourlyForecast: [HourWeather] = []
    @State private var showAbsolute = false

    // MARK: - Constants

    private static let daysOfWeek =
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    // private static let gradientColors: [Color] =
    //     [.blue, .green, .yellow, .orange, .red]
    // The above looks better than using [.blue, .yellow, .red].
    // private static let gradient = Gradient(colors: hueColors)

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

    private var gradient: Gradient {
        let forecastMin = hourlyForecast
            .min { $0.temperature.value < $1.temperature.value }
        let forecastMax = hourlyForecast // also uses < !
            .max { $0.temperature.value < $1.temperature.value }

        let tempMin = fahrenheit(forecastMin!)
        let tempMax = fahrenheit(forecastMax!)

        let realStart = showAbsolute ? bluePercent * tempMin / 100 : redPercent
        let realEnd = showAbsolute ? bluePercent * tempMax / 100 : bluePercent

        // "by" is negative so the gradient goes from blue to red.
        let hueColors = stride(
            from: realEnd, // redish
            to: realStart, // bluish
            by: -0.01
        ).map {
            Color(hue: $0, saturation: 0.8, brightness: 0.8)
        }
        return Gradient(colors: hueColors)
    }

    private let weatherVM = WeatherViewModel.shared

    var body: some View {
        Template {
            if hourlyForecast.isEmpty {
                Text("Forecast data is not available.")
            } else {
                HStack(alignment: .top, spacing: 0) {
                    dayLabels

                    ScrollView(.horizontal) {
                        heatMap(hourlyForecast: hourlyForecast)
                            // Prevent scrollbar from overlapping legend.
                            .padding(.bottom, 10)
                    }
                }

                HStack {
                    Text("Colors:")
                    Text("Relative")
                    Toggle("", isOn: $showAbsolute).labelsHidden()
                    Text("Absolute")
                    Spacer()
                }
                .bold()

                Text(showAbsolute ? absoluteHelp : relativeHelp)
                    .font(.footnote)

                /*
                 // TODO: This is only for verifying the desired gradient range.
                 LinearGradient(
                     gradient: gradient,
                     startPoint: .leading,
                     endPoint: .trailing
                 )
                 */
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
            .frame(height: 50)
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

    private func fahrenheit(_ forecast: HourWeather) -> Double {
        forecast.temperature.converted(to: .fahrenheit).value
    }

    private func heatMap(hourlyForecast: [HourWeather]) -> some View {
        Chart {
            ForEach(hourlyForecast.indices, id: \.self) { index in
                let forecast = hourlyForecast[index]
                mark(forecast: forecast)
            }
        }

        .chartForegroundStyleScale(range: gradient)

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

        .frame(width: 800, height: Double(WeatherService.days * 85))
    }

    // This creates an individual cell in the heat map.
    private func mark(forecast: HourWeather) -> some ChartContent {
        let date = forecast.date
        let temperature = fahrenheit(forecast)

        return Plot {
            RectangleMark(
                // Why do String values work, but Int values do not?
                x: .value("Time", "\(date.hour)"),
                y: .value("Day", date.dayOfWeek),
                width: .ratio(1),
                height: .ratio(1)
            )

            .foregroundStyle(by: .value("Temperature", temperature))

            // Display the temperature on top of the cell.
            .annotation(position: .overlay) {
                Text("\(String(format: "%.0f", temperature))℉")
                    .rotationEffect(.degrees(-90))
                    .font(.body)
                    .frame(width: 55)
            }
        }
        .accessibilityLabel("\(date.md) \(date.h)")
        .accessibilityValue("\(temperature)℉")
        .accessibilityHidden(false)
    }
}
