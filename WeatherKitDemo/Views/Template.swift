import SwiftUI

struct Template<Content: View>: View {
    @StateObject private var locationVM = LocationViewModel.shared

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
                Text("WeatherKit Demo")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                Text("Location: \(locationVM.city), \(locationVM.state)")
                self.content
                Spacer()
            }
            .padding()
        }
    }
}
