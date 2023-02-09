import CoreLocation

extension CLLocationCoordinate2D: Equatable {}

public func == (
    lhs: CLLocationCoordinate2D,
    rhs: CLLocationCoordinate2D
) -> Bool {
    // ulp stands for "unit in the last place"
    // The Double method ulpOfOne is used to compare Double values.
    // See https://developer.apple.com/documentation/swift/double/ulpofone-5gc7y.
    fabs(lhs.latitude - rhs.latitude) < Double.ulpOfOne &&
        fabs(lhs.longitude - rhs.longitude) < Double.ulpOfOne
}
