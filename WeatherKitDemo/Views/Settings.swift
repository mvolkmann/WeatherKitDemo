import SwiftUI

struct Settings: View {
    @Environment(\.dismiss) private var dismiss

    // Used by a UI test to dismiss the sheet that renders this view.
    private var dismissButton: some View {
        Button(" ") { dismiss() } // fails if empty string
            .accessibilityIdentifier("dismiss-button")
            .frame(width: 2, height: 2) // fails if < 2
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                dismissButton
                TemperatureUnitToggle()
            }
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
