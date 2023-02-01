import Charts
import SwiftUI
import WeatherKit

private let markHeight = 70.0 // 90.0
private let markWidth = 30.0

struct HeatMapScreen: View {
    // MARK: - State

    @Environment(
        \.horizontalSizeClass
    ) var horizontalSizeClass: UserInterfaceSizeClass?

    @State private var hourlyForecast: [HourWeather] = []
    @StateObject private var weatherVM = WeatherViewModel.shared

    // MARK: - Constants

    private static let daysOfWeek =
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    // private static let gradientColors: [Color] =
    //     [.blue, .green, .yellow, .orange, .red]
    // The above looks better than using [.blue, .yellow, .red].
    // private static let gradient = Gradient(colors: hueColors)

    // MARK: - Variables

    private var dayLabels: some View {
        VStack(spacing: 0) {
            let startIndex = Date().dayOfWeekNumber - 1
            let range =
                startIndex ..< startIndex + WeatherService.days
            ForEach(range, id: \.self) { index in
                dayLabel(Self.daysOfWeek[index % 7])
            }
        }
    }

    private var heatMapHeight: Double {
        // The + 1 is for the x-axis labels and the key.
        Double(WeatherService.days + 1) * markHeight
    }

    private var heatMapWidth: Double { markWidth * 24 }

    private var helpText: some View {
        let low = weatherVM.useFahrenheit ? "0℉" : "-17.8℃"
        let high = weatherVM.useFahrenheit ? "100℉" : "37.8℃"
        return weatherVM.useAbsoluteColors ?
            Text("absolute-help \(low) \(high)") :
            Text("relative-help")
    }

    private var isWide: Bool { horizontalSizeClass != .compact }

    var body: some View {
        Template {
            if hourlyForecast.isEmpty {
                Text("Forecast data is not available.").font(.title)
            } else {
                ScrollView {
                    HStack(alignment: .top, spacing: 0) {
                        dayLabels
                        ScrollView(.horizontal) {
                            heatMap(hourlyForecast: hourlyForecast)
                                // Prevent scrollbar from overlapping legend.
                                .padding(.bottom, 10)
                        }
                        .if(isWide) { view in
                            view.frame(
                                width: heatMapWidth,
                                height: heatMapHeight
                            )
                        }
                    }
                    // .rotationEffect(.degrees(90))
                }
                .padding(.top)
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
        // TODO: Why does "Mon" in French get elided?
        Text(day.localized)
            .frame(height: markHeight)
            .rotationEffect(Angle.degrees(-90))
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
        .chartForegroundStyleScale(range: weatherVM.gradient)
        // .chartLegend(.hidden) // TODO: Why does this also hide x-axis labels?
        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic) { axisValue in
                AxisTick()
                AxisValueLabel(centered: true) {
                    let index = axisValue.index
                    let mod = index % 12
                    let hour = mod == 0 ? 12 : mod
                    // TODO: Use 24-hour clock in French without AM/PM.
                    Text("\(hour)\n\(index < 12 ? "AM" : "PM")")
                        .multilineTextAlignment(.center)
                }
            }
        }

        // I can't get the y-axis labels to appear to the left of each row.
        // They display above each row.
        .chartYAxis(.hidden)

        .frame(width: heatMapWidth, height: heatMapHeight)
    }

    // This creates an individual cell in the heat map.
    private func mark(forecast: HourWeather) -> some ChartContent {
        let date = forecast.date
        let measurement = weatherVM.showFeel ?
            forecast.apparentTemperature : forecast.temperature
        let temperature = measurement.converted

        /*
         // TODO: Is there a bug that sometimes causes temperatures to be elided?
         let t = String(format: "%.0f", temperature)
         print("temperature = \(temperature), t = \(t)")
         */

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
                Text(
                    "\(String(format: "%.0f", temperature))" +
                        weatherVM.temperatureUnitSymbol
                )
                .rotationEffect(.degrees(-90))
                .font(.body)
                .frame(width: 60)
            }
        }
        .accessibilityLabel("\(date.md) \(date.h)")
        .accessibilityValue("\(temperature)" + weatherVM.temperatureUnitSymbol)
        .accessibilityHidden(false)
    }
}
