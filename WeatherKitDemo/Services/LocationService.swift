import CoreLocation
import SwiftUI

struct LocationService {
    static func description(from placemark: CLPlacemark?) -> String {
        guard let placemark else { return "" }
        let city = Self.city(from: placemark)
        let state = Self.state(from: placemark)
        let country = Self.country(from: placemark)
        return state == city ? "\(city), \(country)" : "\(city), \(state)"
    }

    static func city(from placemark: CLPlacemark?) -> String {
        placemark?.locality ?? ""
    }

    static func country(from placemark: CLPlacemark?) -> String {
        placemark?.country ?? ""
    }

    static func getPlacemark(from location: CLLocation) async throws
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

    static func getPlacemarks(from addressString: String) async throws
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

    static func state(from placemark: CLPlacemark?) -> String {
        placemark?.administrativeArea ?? ""
    }
}
