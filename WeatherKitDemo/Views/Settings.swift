import SwiftUI

struct Settings: View {
    var body: some View {
        VStack(spacing: 20) {
            TemperatureUnitToggle()
            ActualFeelToggle()
            ChartDaysSlider()
            HeatMapToggle()
            ColorToggle()
            Spacer()
        }
        .padding(.top, 30)
        .padding(.horizontal)
    }
}
