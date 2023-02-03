import Charts
import SwiftUI
import WeatherKit

private let markHeight = 70.0
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
        // Create an array of the day abbreviations to appear in the heat map.
        var days: [String] = []
        let startDayNumber = Date().dayOfWeekNumber
        let endDayNumber = startDayNumber + WeatherService.days
        for dayNumber in stride(
            from: endDayNumber - 1,
            to: startDayNumber - 1,
            by: -1
        ) {
            days.append(Self.daysOfWeek[(dayNumber - 1) % 7])
        }

        // Instead of showing the abbreviation of the day for today,
        // display the word "Today".
        days[WeatherService.days - 1] = "Today"

        return VStack(spacing: 0) {
            ForEach(days, id: \.self) { day in dayLabel(day) }
        }
    }

    private var daysOnTop: Bool { weatherVM.heatMapDaysOnTop }

    private var heatMapHeight: Double {
        // TODO: Change 350 to something based on the screen width.
        let result = daysOnTop ? 350 : // markWidth * 24 :
            // The + 1 is for the x-axis labels and the key.
            Double(WeatherService.days + 1) * markHeight
        print("heatMapHeight =", result)
        return result
    }

    private var heatMapWidth: Double {
        // TODO: Can we calculate the value instead of using 700?
        let result = daysOnTop ? 700 :
            // The + 1 is for the x-axis labels and the key.
            // Double(WeatherService.days + 1) * markHeight :
            markWidth * 24
        print("heatMapWidth =", result)
        return result
    }

    private var helpText: some View {
        let low = weatherVM.useFahrenheit ? "0℉" : "-17.8℃"
        let high = weatherVM.useFahrenheit ? "100℉" : "37.8℃"
        return weatherVM.useAbsoluteColors ?
            Text("absolute-help \(low) \(high)") :
            Text("relative-help")
    }

    private var isWide: Bool { horizontalSizeClass != .compact }

    // This reorders the hourly forecasts so the dates are in reverse order.
    // It is needed so the bottom row can be for today
    // and the top row can be for four days later.
    private var sortedHourlyForecast: [HourWeather] {
        var sorted: [HourWeather] = []
        let days = WeatherService.days
        for index in 0 ..< days {
            let startIndex = (days - 1 - index) * 24
            let slice = hourlyForecast[startIndex ..< startIndex + 24]
            sorted.append(contentsOf: slice)
        }
        return sorted
    }

    var body: some View {
        Template {
            if hourlyForecast.isEmpty {
                Text("Forecast data is not available.").font(.title)
            } else {
                HStack(alignment: .top, spacing: 0) {
                    dayLabels
                    ScrollView(.horizontal) {
                        heatMap(hourlyForecast: sortedHourlyForecast)
                            // Prevent scrollbar from overlapping legend.
                            .padding(.bottom, daysOnTop ? 0 : 10)
                            .border(.green)
                    }
                    // .frame(width: daysOnTop ? 450 : nil)
                    .if(isWide) { view in
                        view.frame(
                            width: heatMapWidth,
                            height: heatMapHeight
                        )
                    }
                    .border(.red)
                }
                .rotationEffect(.degrees(daysOnTop ? 90 : 0))
                .padding(.top)
            }
        }
        // Run this closure again every time the selected placemark changes.
        .task(id: weatherVM.summary) {
            print("HeatMapScreen: daysOnTop =", daysOnTop)
            print("HeatMapScreen: isWide =", isWide)
            if let summary = weatherVM.summary {
                hourlyForecast = summary.hourlyForecast
            }
        }
    }

    // MARK: - Methods

    private func dayLabel(_ day: String) -> some View {
        // TODO: Why does "Mon" in French get elided?
        Text(day.localized)
            .frame(height: daysOnTop ? markHeight * 0.91 : markHeight)
            .rotationEffect(Angle.degrees(-90))
    }

    private func heatMap(hourlyForecast: [HourWeather]) -> some View {
        Chart {
            ForEach(hourlyForecast.reversed().indices, id: \.self) { index in
                let forecast = hourlyForecast[index]
                mark(forecast: forecast)
            }
        }
        .chartForegroundStyleScale(range: weatherVM.gradient)

        // I can't get legend to render in a good place when daysOnTop is true.
        // TODO: Why does hiding the legend also hide x-axis labels?
        .chartLegend(daysOnTop ? .hidden : .visible)

        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic) { axisValue in
                AxisTick()
                AxisValueLabel(
                    centered: true,
                    orientation: daysOnTop ? .verticalReversed : .horizontal
                ) {
                    let index = axisValue.index
                    let mod = index % 12
                    let hour = mod == 0 ? 12 : mod
                    // TODO: Use 24-hour clock in French without AM/PM.
                    Text("\(hour)\n\(index < 12 ? "AM" : "PM")")
                        .multilineTextAlignment(.center)
                        .frame(width: daysOnTop ? 27 : nil)
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
                // .font(.body)
                .font(.system(size: daysOnTop ? 13 : 17))
                .frame(width: 60)
            }
        }
        .accessibilityLabel("\(date.md) \(date.h)")
        .accessibilityValue("\(temperature)" + weatherVM.temperatureUnitSymbol)
        .accessibilityHidden(false)
    }
}
