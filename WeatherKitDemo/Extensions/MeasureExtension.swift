import SwiftUI

extension Measurement<UnitTemperature> {
    /// Temperature in Celsius or Fahrenheit based on the value of `showFahrenheit`.
    var converted: Double {
        let useFahrenheit = WeatherViewModel.shared.useFahrenheit
        return converted(to: useFahrenheit ? .fahrenheit : .celsius).value
    }

    var fahrenheit: Double {
        return converted(to: .fahrenheit).value
    }
}
