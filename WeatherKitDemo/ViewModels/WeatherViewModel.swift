import SwiftUI

class WeatherViewModel: NSObject, ObservableObject {
    @Published var summary: WeatherSummary?

    // This is a singleton class.
    static let shared = WeatherViewModel()
    override private init() {}
}
