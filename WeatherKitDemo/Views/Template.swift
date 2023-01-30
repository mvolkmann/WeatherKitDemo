import SwiftUI

struct Template<Content: View>: View {
    // MARK: - State

    @AppStorage("likedLocations") var likedLocations: String = ""

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) var scenePhase

    @State private var location: String = ""
    @State private var isLiked: Bool = false

    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    // MARK: - Initializer

    // This is needed to use @ViewBuilder.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - Properties

    private var background: some View {
        Rectangle()
            .fill(backgroundColor)
            .opacity(0.3)
            .ignoresSafeArea()
    }

    // Static stored properties are not supported in generic types,
    // so we cannot make this a static constant.
    private let backgroundColor = LinearGradient(
        gradient: Gradient(colors: [.blue, .purple]),
        startPoint: .top,
        endPoint: .bottom
    )

    private let content: Content

    private var likeButton: some View {
        Button(
            action: {
                isLiked.toggle()

                if let place = locationVM.selectedPlacemark {
                    let location = LocationService.description(from: place)

                    if isLiked {
                        locationVM.likeLocation(location)
                    } else {
                        locationVM.unlikeLocation(location)
                    }

                    // Persist in AppStorage.   We cannot use comma for
                    // separator because some locations contain commas.
                    likedLocations =
                        locationVM.likedLocations.joined(separator: "|")
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
        Text(location).font(.title2).bold()
    }

    private var title: some View {
        VStack {
            Text("Feather Weather")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            if weatherVM.timestamp != nil {
                HStack {
                    Text("last updated")
                    Text(weatherVM.formattedTimestamp)
                    Button("Refresh") { refresh() }
                }
            }
        }
    }

    var body: some View {
        ZStack {
            background
            VStack {
                title

                HStack {
                    place
                    if !location.isEmpty { likeButton }
                }

                if locationVM.authorized && weatherVM.summary == nil {
                    Spacer()
                    LottieView(name: "weather-progress", loopMode: .loop)
                        .frame(width: 200, height: 200)
                } else {
                    self.content
                }

                Spacer()
            }
            .padding()
        }

        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active { refresh() }
        }

        // We are using task instead of onAppear so we can specify a dependency.
        .task(id: locationVM.selectedPlacemark) {
            // likedLocations = "" // uncomment to reset AppStorage

            location = LocationService.description(
                from: locationVM.selectedPlacemark
            )
            isLiked = locationVM.isLikedLocation(location)

            if locationVM.likedLocations.isEmpty {
                // Restore from AppStorage.
                locationVM.likedLocations =
                    likedLocations.split(separator: "|").map(String.init)
            }
        }
    }

    // MARK: - Methods

    private func refresh() {
        guard let location = locationVM.selectedPlacemark?.location
        else { return }

        Task {
            try? await weatherVM.load(
                location: location,
                colorScheme: colorScheme
            )
        }
    }
}
