import SwiftUI

struct Settings: View {
    var body: some View {
        VStack {
            TemperatureUnitToggle()
            ActualFeelToggle()
            ColorToggle()
            Spacer()
        }
        .padding(.top, 10)
        .padding()
    }
}
