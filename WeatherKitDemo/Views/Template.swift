import SwiftUI

struct Template<Content: View>: View {
    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    let content: Content

    // This is needed to use @ViewBuilder.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            VStack {
                Text("Feather Weather")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                Text("\(locationVM.city), \(locationVM.state)")
                    .font(.title2)
                if weatherVM.summary == nil {
                    Spacer()
                    ProgressView()
                } else {
                    self.content
                }
                Spacer()
            }
            .padding()
        }
    }
}
