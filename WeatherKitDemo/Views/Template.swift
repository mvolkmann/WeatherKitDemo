import SwiftUI

struct Template<Content: View>: View {
    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    private let backgroundColor = LinearGradient(
        gradient: Gradient(colors: [.blue, .purple]),
        startPoint: .top,
        endPoint: .bottom
    )

    private let content: Content

    // This is needed to use @ViewBuilder.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .opacity(0.3)
                .ignoresSafeArea()
            VStack {
                Text("Feather Weather")
                    .font(.largeTitle)
                    .foregroundColor(.primary)

                Text(LocationService.description(
                    from: locationVM.selectedPlacemark
                ))
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
