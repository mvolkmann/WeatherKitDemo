import Charts
import SwiftUI
import WeatherKit

struct ChartScreen: View {
    @AppStorage("chartDays") private var chartDays = WeatherService.days
    @AppStorage("showFahrenheit") private var showFahrenheit = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedDate: Date?
    @StateObject private var weatherVM = WeatherViewModel.shared

    private let areaColor = LinearGradient(
        gradient: Gradient(colors: [.green, .blue]),
        startPoint: .top,
        endPoint: .bottom
    )

    private var annotation: some View {
        VStack {
            if let date = selectedDate,
               let temperature = weatherVM.dateToTemperatureMap[date] {
                Text(date.formatted(.dateTime.weekday(.wide)))
                Text(date.formatted(.dateTime.hour()))
                Text(
                    String(format: "%.0f", temperature.converted) +
                        weatherVM.temperatureUnitSymbol
                )
            }
        }
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(annotationFill)
        }
        .foregroundColor(Color(.label))
    }

    private var annotationFill: some ShapeStyle {
        let fillColor: Color = colorScheme == .light ?
            .white : Color(.secondarySystemBackground)
        return fillColor.shadow(.drop(radius: 3))
    }

    private var temperatureDomain: ClosedRange<Double> {
        var low = weatherVM.forecastTempMin
        if !showFahrenheit { low = fToC(low) }
        var high = weatherVM.forecastTempMax
        if !showFahrenheit { high = fToC(high) }
        return min(0, low) ... high
    }

    private func fToC(_ fahrenheit: Double) -> Double {
        var measurement =
            Measurement<UnitTemperature>(
                value: fahrenheit,
                unit: .fahrenheit
            )
        measurement.convert(to: .celsius)
        return measurement.value
    }

    var body: some View {
        Template(parent: "chart") {
            let futureForecast =
                weatherVM.futureForecast.prefix(chartDays * 24)
            Text("drag-help")
                .accessibilityIdentifier("drag-help")
                .font(.subheadline)
                .padding(.top)
            ZStack(alignment: .top) {
                HStack {
                    Text("Temperature")
                        .accessibilityIdentifier("temperature-label")
                        .opacity(0.5)
                        .padding(.top, 45)
                    Spacer()
                }

                Chart {
                    ForEach(futureForecast.indices, id: \.self) { index in
                        let forecast = futureForecast[index]
                        let date = PlottableValue.value(
                            "Date",
                            forecast.date
                        )
                        let temperature = PlottableValue.value(
                            "Temperature",
                            forecast.converted
                        )

                        LineMark(x: date, y: temperature)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3))

                        // PointMark(x: date, y: temperature)

                        AreaMark(x: date, y: temperature)
                            .foregroundStyle(areaColor.opacity(0.6))

                        if selectedDate == forecast.date {
                            RuleMark(x: date)
                                .annotation(
                                    position: annotationPosition(index)
                                ) {
                                    annotation
                                }
                                // Display a red, dashed, vertical line.
                                .foregroundStyle(.red)
                                .lineStyle(StrokeStyle(dash: [10, 5]))
                        }
                    }
                }
                .padding(.top, 80) // leaves room for top annotation
                .chartYAxis { AxisMarks(position: .leading) }
                // This fixes the chart jump issue during dragging.
                // See https://developer.apple.com/forums/thread/724770.
                .chartYScale(domain: temperatureDomain)
                .chartOverlay { proxy in chartOverlay(proxy: proxy) }
            }
        }
    }

    // This chooses a position based on whether
    // the data point is near one of the chart edges.
    private func annotationPosition(_ index: Int) -> AnnotationPosition {
        let percent = Double(index) / Double(chartDays * 24)
        // These percent values work well for iPhone SE.
        return percent < 0.20 ? .topTrailing :
            percent >= 0.80 ? .topLeading :
            .top
    }

    private func chartOverlay(proxy: ChartProxy) -> some View {
        GeometryReader { geometry in // of the overlay view
            let origin = geometry[proxy.plotAreaFrame].origin
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())

                // Handle drag gestures.
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let location = CGPoint(
                                x: value.location.x - origin.x,
                                y: value.location.y - origin.y
                            )
                            if let (date, _) = proxy.value(
                                at: location,
                                as: (Date, Double)
                                    .self // date and temperature
                            ) {
                                selectedDate = date.removeSeconds()
                            }
                        }
                        .onEnded { _ in
                            selectedDate = nil
                        }
                )
        }
    }
}
