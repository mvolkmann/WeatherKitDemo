import Combine // TODO: really need this?
import CoreLocation
import MapKit
import SwiftUI

// Add these keys in Info of each target that queries current location:
// Privacy - Location When In Use Usage Description
// Privacy - Location Always and When In Use Usage Description
class LocationViewModel: NSObject, ObservableObject {
    // MARK: - State

    @Published var searchPlacemarks: [CLPlacemark] = []
    @Published var currentPlacemark: CLPlacemark?
    @Published var searchQuery = ""
    @Published var selectedPlacemark: CLPlacemark?

    // MARK: - Initializer

    override init() {
        // This must precede the call to super.init.
        completer = MKLocalSearchCompleter()

        super.init()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        // locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self

        cancellable = $searchQuery.assign(to: \.queryFragment, on: completer)
        completer.delegate = self
    }

    // MARK: - Properites

    static let shared = LocationViewModel()

    private var cancellable: AnyCancellable?
    private var completer: MKLocalSearchCompleter
    private let locationManager = CLLocationManager()

    var city: String {
        LocationService.city(from: selectedPlacemark)
    }

    var country: String {
        LocationService.country(from: selectedPlacemark)
    }

    var state: String {
        LocationService.state(from: selectedPlacemark)
    }

    var usingCurrent: Bool {
        selectedPlacemark != nil && selectedPlacemark == currentPlacemark
    }

    // MARK: - Methods

    func select(placemark: CLPlacemark) {
        selectedPlacemark = placemark
        searchQuery = ""
        searchPlacemarks = []
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(
        _: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        // If we already have the placemark, return.
        guard currentPlacemark == nil else { return }

        if let location = locations.first {
            CLGeocoder().reverseGeocodeLocation(
                location
            ) { [weak self] placemarks, error in
                if let error {
                    print("LocationViewModel: error =", error)
                } else if let self {
                    self.currentPlacemark = placemarks?.first
                    self.selectedPlacemark = self.currentPlacemark
                    // Once we have the location, stop trying to update it.
                    self.locationManager.stopUpdatingLocation()
                }
            }
        }
    }
}

extension LocationViewModel: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task {
            do {
                let placemarks = try await loadPlacemarks(
                    completions: completer.results
                )
                await MainActor.run { searchPlacemarks = placemarks }
            } catch {
                print("LocationViewModel error:", error)
            }
        }
    }

    private func loadPlacemarks(
        completions: [MKLocalSearchCompletion]
    ) async throws -> [CLPlacemark] {
        try await withThrowingTaskGroup(of: CLPlacemark?.self) { group in
            var resultPlacemarks: [CLPlacemark] = []
            resultPlacemarks.reserveCapacity(completions.count)

            for completion in completions {
                group.addTask {
                    try? await LocationService.getPlacemark(
                        from: completion.title
                    )
                }
            }

            for try await placemark in group {
                if let placemark {
                    resultPlacemarks.append(placemark)
                }
            }

            resultPlacemarks.sort(by: { $0.description < $1.description })
            return resultPlacemarks
        }
    }
}
