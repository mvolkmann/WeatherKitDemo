import CoreLocation
import SwiftUI

// Add these keys in Info of each target that queries current location:
// Privacy - Location When In Use Usage Description
// Privacy - Location Always and When In Use Usage Description
class LocationViewModel: NSObject, ObservableObject {
    @Published var city = ""
    @Published var location: CLLocation?
    @Published var state = ""

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

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(
        _: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        // If we already have the location, return.
        guard location == nil else { return }

        // If no location is currently available, return.

        if let newLocation = locations.last {
            DispatchQueue.main.async { self.location = newLocation }
            CLGeocoder()
                .reverseGeocodeLocation(newLocation) { placemark, error in
                    if let error {
                        print("LocationService: error =", error)
                    } else {
                        if let place = placemark?.first {
                            self.city = place.locality ?? "unknown"
                            self.state = place.administrativeArea ?? "unknown"
                        }
                    }
                }
        }
    }
}
