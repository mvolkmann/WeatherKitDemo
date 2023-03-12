import SwiftUI

struct Template<Content: View>: View {
    // MARK: - State

    @AppStorage("likedLocations") private var likedLocations: String = ""
    @AppStorage("showFeel") private var showFeel = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) var scenePhase

    @State private var selectedLocation: String = ""
    @State private var locations: [String] = []
    @State private var isLiked: Bool = false
    @State private var lastScenePhase = ScenePhase.inactive

    @StateObject private var locationVM = LocationViewModel.shared
    @StateObject private var weatherVM = WeatherViewModel.shared

    // MARK: - Initializer

    // This is needed to use @ViewBuilder.
    init(parent: String, @ViewBuilder content: () -> Content) {
        self.parent = parent
        self.content = content()
    }

    // MARK: - Properties

    private let parent: String

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

    private var heading: some View {
        VStack(spacing: 0) {
            HStack {
                if !selectedLocation.isEmpty {
                    place
                    likeButton
                }
            }

            if weatherVM.timestamp != nil {
                HStack {
                    Text("last updated")
                    Text(weatherVM.formattedTimestamp)
                }
                .font(.system(size: 16))
                let tempKind = showFeel ? "feels like" : "actual"
                Text("showing \(tempKind) temperatures".localized)
            }
        }
    }

    private var icon: String {
        locationVM.isLikedLocation(selectedLocation) ? "heart.fill" : "heart"
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
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .tint(.red)
            }
        )
    }

    private var place: some View {
        /*
         Text(location)
             .lineLimit(1)
             .font(.body)
             .minimumScaleFactor(0.75)
             .bold()
         */
        Picker("Location", selection: $selectedLocation) {
            ForEach(locations, id: \.self) { location in
                Text(location)
            }
        }
        .frame(maxWidth: .infinity)
        #if os(iOS)
            .pickerStyle(.menu)
        #endif
            .onChange(of: selectedLocation) { _ in
                selectLocation(selectedLocation)
            }
    }

    var body: some View {
        ZStack(alignment: .top) {
            background
            VStack(spacing: 0) {
                heading

                if locationVM.authorized && weatherVM.summary == nil {
                    Spacer()
                    LottieView(name: "weather-progress", loopMode: .loop)
                        .frame(width: 200, height: 200)
                    if weatherVM.isSlow {
                        Text("weatherkit-slow").font(.title2)
                    }
                } else {
                    self.content
                }

                Spacer()
            }
            .padding(.horizontal)
        }

        .onChange(of: scenePhase) { _ in
            // This is invoked once for each screen in the app
            // because every screen uses this Template struct.
            // But we only want to process this once.
            guard parent == "current" else { return }

            // Check for change from .background to .inactive.
            if lastScenePhase == .background, scenePhase == .inactive {
                lastScenePhase = scenePhase
                refreshForecast()
            } else {
                lastScenePhase = scenePhase
            }
        }

        .onChange(of: locationVM.likedLocations) { _ in
            updateLocations()
        }

        // We are using task instead of onAppear so we can specify a dependency.
        .task(id: locationVM.selectedPlacemark) {
            // likedLocations = "" // uncomment to reset AppStorage

            selectedLocation = LocationService.description(
                from: locationVM.selectedPlacemark
            )
            isLiked = locationVM.isLikedLocation(selectedLocation)

            if locationVM.likedLocations.isEmpty {
                // Restore from AppStorage.
                locationVM.likedLocations =
                    likedLocations.split(separator: "|").map(String.init)
            }

            updateLocations()
        }
    }

    // MARK: - Methods

    private func refreshForecast() {
        guard let location = locationVM.selectedPlacemark?.location else {
            return
        }

        Task {
            try? await weatherVM.load(
                location: location,
                colorScheme: colorScheme
            )
        }
    }

    private func selectLocation(_ location: String) {
        Task {
            do {
                let placemark = try await LocationService
                    .getPlacemark(from: location)
                locationVM.select(placemark: placemark)
            } catch {
                Log.error("error getting placemark: \(error)")
            }
        }
    }

    // These are used in the Picker.
    private func updateLocations() {
        locations = []
        let currentLocation = LocationService.description(
            from: locationVM.selectedPlacemark
        )
        let liked = locationVM.likedLocations
        if !currentLocation.isEmpty, !liked.contains(currentLocation) {
            locations = [currentLocation]
        }
        locations.append(contentsOf: liked)
    }
}
