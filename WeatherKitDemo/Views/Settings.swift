import SwiftUI

struct Settings: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .accessibilityIdentifier("settings-title")
                .font(.headline)
                .onTapGesture { dismiss() }
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
