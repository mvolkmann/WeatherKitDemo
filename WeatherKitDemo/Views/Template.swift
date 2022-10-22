import SwiftUI

struct Template<Content: View>: View {
    @AppStorage("likedLocations") var likedLocations: String = ""

    @State private var location: String = ""
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
        Text(location).font(.title2)
    }

    private var title: some View {
        VStack {
            Text("Feather Weather")
                .font(.largeTitle)
                .foregroundColor(.primary)
            if weatherVM.timestamp != nil {
                Text("last updated \(weatherVM.formattedTimestamp)")
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
                    likeButton
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
}
