import Combine // for AnyCancellable
import CoreLocation
import MapKit
import SwiftUI

// Add these keys in Info of each target that queries current location:
// Privacy - Location When In Use Usage Description
// Privacy - Location Always and When In Use Usage Description
class LocationViewModel: NSObject, ObservableObject {
    // MARK: - State

    @Published var authorized: Bool = false
    @Published var searchLocations: [String] = []
    @Published var currentPlacemark: CLPlacemark?
    @Published var likedLocations: [String] = []
    @Published var searchQuery = ""
    @Published var selectedPlacemark: CLPlacemark?

    // MARK: - Initializer

    override init() {
        // This must precede the call to super.init.
        completer = MKLocalSearchCompleter()

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        cancellable = $searchQuery.assign(to: \.queryFragment, on: completer)
        completer.delegate = self
        // Does this prevent getting points of interest like restaurants?
        completer.resultTypes = .address
    }

    // MARK: - Properties

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

    var timeZone: TimeZone? {
        selectedPlacemark?.timeZone
    }

    var usingCurrent: Bool {
        selectedPlacemark != nil && selectedPlacemark == currentPlacemark
    }

    // MARK: - Methods

    func getTimeZone() async throws -> TimeZone {
        guard let location = selectedPlacemark?.location else {
            throw "no placemark selected"
        }

        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let pm = placemarks.first else {
            throw "reverse geocode failed"
        }
        return pm.timeZone!
    }

    func isLikedLocation(_ location: String) -> Bool {
        likedLocations.contains(location)
    }

    func likeLocation(_ location: String) {
        likedLocations.append(location)
        likedLocations.sort()
    }

    func select(placemark: CLPlacemark) {
        selectedPlacemark = placemark
        searchQuery = ""
        searchLocations = []
    }

    func unlikeLocation(_ location: String) {
        likedLocations.removeAll(where: { $0 == location })
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        authorized =
            status == .authorizedAlways || status == .authorizedWhenInUse
    }

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
                    Log.error("error getting reverse geolocation: \(error)")
                } else if let self {
                    let placemark = placemarks?.first
                    self.currentPlacemark = placemark
                    self.selectedPlacemark = placemark

                    // Once we have the location, stop trying to update it.
                    self.locationManager.stopUpdatingLocation()
                }
            }
        }
    }
}

extension LocationViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        var locations = completer.results.map { result in
            result.title + ", " + result.subtitle
        }
        locations.sort()
        searchLocations = locations
    }
}
