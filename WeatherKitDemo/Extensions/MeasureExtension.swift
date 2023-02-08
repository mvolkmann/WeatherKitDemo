import SwiftUI

extension Measurement<UnitTemperature> {
    /// Temperature in Celsius or Fahrenheit based on the value of `showFahrenheit`.
    var converted: Double {
        let showFahrenheit =
            UserDefaults.standard.bool(forKey: "showFahrenheit")
        return converted(to: showFahrenheit ? .fahrenheit : .celsius).value
    }

    var fahrenheit: Double {
        return converted(to: .fahrenheit).value
    }
}
