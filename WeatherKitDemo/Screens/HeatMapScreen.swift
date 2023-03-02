import Charts
import SwiftUI
import WeatherKit

private let markHeight = 70.0
private let markWidth = 30.0

struct HeatMapScreen: View {
    // MARK: - State

    @AppStorage("heatMapDaysOnTop") private var heatMapDaysOnTop = false
    @AppStorage("showAbsoluteColors") private var showAbsoluteColors = false
    @AppStorage("showFahrenheit") private var showFahrenheit = false
    @AppStorage("showFeel") private var showFeel = false
    @Environment(
        \.horizontalSizeClass
    ) var horizontalSizeClass: UserInterfaceSizeClass?
    @State private var hourlyForecast: [HourWeather] = []
    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    // MARK: - Constants

    private static let daysOfWeek =
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    // private static let gradientColors: [Color] =
    //     [.blue, .green, .yellow, .orange, .red]
    // The above looks better than using [.blue, .yellow, .red].
    // private static let gradient = Gradient(colors: hueColors)

    // MARK: - Properties

    private var currentHour: Int { Date().hour }

    private var dayLabels: some View {
        // Create an array of the day abbreviations to appear in the heat map.
        var days: [String] = []
        let date = Date.current
        let targetDate = date.hoursAfter(date.timeZoneOffset)
        let startDayNumber = targetDate.dayOfWeekNumber
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
            ForEach(days.indices, id: \.self) { index in
                dayLabel(index: index, day: days[index])
            }
        }
    }

    private var heatMapHeight: Double {
        // TODO: Change 350 to something based on the screen width.
        let result = heatMapDaysOnTop ? 350 : // markWidth * 24 :
            // The + 1 is for the x-axis labels and the key.
            Double(WeatherService.days + 1) * markHeight
        return result
    }

    private var heatMapWidth: Double {
        // TODO: Can this value be calculated instead of using 700?
        let result = heatMapDaysOnTop ? 700 :
            // The + 1 is for the x-axis labels and the key.
            // Double(WeatherService.days + 1) * markHeight :
            markWidth * 24
        return result
    }

    private var helpText: some View {
        let low = showFahrenheit ? "0℉" : "-17.8℃"
        let high = showFahrenheit ? "100℉" : "37.8℃"
        return showAbsoluteColors ?
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
        Template(parent: "heatmap") {
            if hourlyForecast.isEmpty {
                ProgressView()
            } else {
                HStack(alignment: .top, spacing: 0) {
                    dayLabels
                    ScrollView(.horizontal) {
                        heatMap(hourlyForecast: sortedHourlyForecast)
                            // Prevent scrollbar from overlapping legend.
                            .padding(.bottom, heatMapDaysOnTop ? 0 : 10)
                    }

                    // TODO: Why does this cause dayLabels to disappear?
                    // .frame(width: daysOnTop ? 500 : nil)

                    .if(isWide) { view in
                        view.frame(
                            width: heatMapWidth,
                            height: heatMapHeight
                        )
                    }
                }
                .rotationEffect(
                    .degrees(heatMapDaysOnTop ? 90 : 0)
                    // The default anchor value is .center and
                    // that seems much better than all the other options.
                )
                // .offset(y: daysOnTop ? 150 : 0)
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

    private func dayLabel(index: Int, day: String) -> some View {
        Text(day.localized)
            .accessibilityIdentifier("day-label-\(index)")
            .frame(height: heatMapDaysOnTop ? markHeight * 0.91 : markHeight)
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
        .chartLegend(heatMapDaysOnTop ? .hidden : .visible)

        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic) { axisValue in
                AxisTick()
                AxisValueLabel(
                    centered: true,
                    orientation:
                    heatMapDaysOnTop ? .verticalReversed : .horizontal
                ) {
                    let index = axisValue.index
                    let mod = index % 12
                    let hour = mod == 0 ? 12 : mod
                    let isCurrentHour = index == currentHour

                    // This honors the Settings ... General ...
                    // Date & Time ... 24-Hour Time switch.
                    let is24Hour = Date.is24Hour()
                    let text = is24Hour ?
                        (index == 0 ? "12" : "\(index)") :
                        "\(hour)\n\(index < 12 ? "AM" : "PM")"
                    Text(text)
                        .fontWeight(isCurrentHour ? .bold : .regular)
                        .foregroundColor(isCurrentHour ? .red : .black)
                        .multilineTextAlignment(.center)
                        .frame(
                            width: heatMapDaysOnTop ?
                                (is24Hour ? 22 : 27) : nil,
                            height: heatMapDaysOnTop && is24Hour ? 22 : nil
                        )
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
        let day = date.hoursAfter(date.timeZoneOffset).dayOfWeek
        let measurement = showFeel ?
            forecast.apparentTemperature : forecast.temperature
        let temperature = measurement.converted
        let isCurrentHour = date.hour == currentHour

        return Plot {
            RectangleMark(
                // Why do String values work, but Int values do not?
                x: PlottableValue.value("Time", "\(date.hour)"),
                y: PlottableValue.value("Day", day),
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
                .fontWeight(isCurrentHour ? .bold : .regular)
                .rotationEffect(.degrees(-90))
                // .font(.body)
                .font(.system(size: heatMapDaysOnTop ? 13 : 17))
                .frame(width: 60)
            }
        }
        .accessibilityLabel("\(date.md) \(date.h)")
        .accessibilityValue("\(temperature)" + weatherVM.temperatureUnitSymbol)
        .accessibilityHidden(false)
    }
}
