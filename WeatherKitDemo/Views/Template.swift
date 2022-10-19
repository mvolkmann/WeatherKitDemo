import SwiftUI

struct Template<Content: View>: View {
    @State private var description: String = ""
    @State private var isLiked: Bool = false

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

    private var background: some View {
        Rectangle()
            .fill(backgroundColor)
            .opacity(0.3)
            .ignoresSafeArea()
    }

    private var likeButton: some View {
        Button(
            action: {
                isLiked.toggle()

                if let place = locationVM.selectedPlacemark {
                    let description = LocationService.description(from: place)
                    if isLiked {
                        locationVM.likePlace(description)
                    } else {
                        locationVM.unlikePlace(description)
                    }
                }
            },
            label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .tint(.red)
            }
        )
    }

    private var place: some View {
        Text(description).font(.title2)
    }

    private var title: some View {
        Text("Feather Weather")
            .font(.largeTitle)
            .foregroundColor(.primary)
    }

    var body: some View {
        ZStack {
            background
            VStack {
                title

                HStack {
                    place
                    likeButton
                }

                VStack {
                    Text("You like these:")
                    ForEach(locationVM.likedPlaces, id: \.self) {
                        Text($0)
                    }
                }

                if weatherVM.summary == nil {
                    Spacer()
                    ProgressView()
                        .frame(width: 100, height: 100)
                } else {
                    self.content
                }

                Spacer()
            }
            .padding()
        }
        // Using task instead of onAppear so we can specify a dependency.
        .task(id: locationVM.selectedPlacemark) {
            description = LocationService.description(
                from: locationVM.selectedPlacemark
            )
            isLiked = locationVM.isLikedPlace(description)
        }
    }
}
