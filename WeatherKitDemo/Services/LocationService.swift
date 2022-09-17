import CoreLocation
import SwiftUI

// Add these keys in Info of each target that queries current location:
// Privacy - Location When In Use Usage Description
// Privacy - Location Always and When In Use Usage Description
class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(
        _: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        // If we already have the current location or
        // no location is currently available, return.
        guard currentLocation == nil, let location = locations.last else {
            return
        }

        // Save the location.
        DispatchQueue.main.async {
            self.currentLocation = location
        }
    }
}
