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
