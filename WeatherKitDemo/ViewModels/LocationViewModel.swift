import CoreLocation
import SwiftUI

// Add these keys in Info of each target that queries current location:
// Privacy - Location When In Use Usage Description
// Privacy - Location Always and When In Use Usage Description
class LocationViewModel: NSObject, ObservableObject {
    // MARK: - State

    @Published var currentPlacemark: CLPlacemark?
    @Published var selectedPlacemark: CLPlacemark?

    // MARK: - Initializer

    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }

    // MARK: - Properites

    static let shared = LocationViewModel()

    private let locationManager = CLLocationManager()

    var city: String {
        selectedPlacemark?.locality ?? "unknown"
    }

    var state: String {
        selectedPlacemark?.administrativeArea ?? "unknown"
    }

    var usingCurrent: Bool {
        selectedPlacemark != nil && selectedPlacemark == currentPlacemark
    }

    // MARK: - Methods

    static func getPlacemark(location: CLLocation) async throws
        -> CLPlacemark? {
        try await withCheckedThrowingContinuation { continuation in
            CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: placemark?.first)
                }
            }
        }
    }

    static func getPlacemarks(addressString: String) async throws
        -> [CLPlacemark] {
        try await withCheckedThrowingContinuation { continuation in
            let geocoder = CLGeocoder()
            print(
                "LocationViewModel.getPlacemarks: addressString =",
                addressString
            )
            geocoder.geocodeAddressString(addressString) { placemarks, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let placemarks {
                    print(
                        "LocationViewModel.getPlacemarks: placemarks =",
                        placemarks
                    )
                    continuation.resume(returning: placemarks)
                } else {
                    continuation.resume(throwing: "no placemarks found")
                }
            }
        }
    }

    func resetPlacemark() {
        selectedPlacemark = currentPlacemark
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(
        _: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        // If we already have the placemark, return.
        guard currentPlacemark == nil else { return }

        // TODO: Why last instead of first?
        if let location = locations.last {
            CLGeocoder()
                .reverseGeocodeLocation(location) { placemarks, error in
                    if let error {
                        print("LocationService: error =", error)
                    } else {
                        self.currentPlacemark = placemarks?.first
                        self.selectedPlacemark = self.currentPlacemark
                    }
                }
        }
    }
}
