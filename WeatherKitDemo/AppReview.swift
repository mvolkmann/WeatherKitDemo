import SwiftUI

struct AppReview {
    // We only want to prompt for an app review if the user
    // has visited all the screens in the app multiple times.
    // That way they should know enough about the app
    // to leave an informed review.
    @AppStorage("chartVisits") private var chartVisits = 0
    @AppStorage("currentVisits") private var currentVisits = 0
    @AppStorage("forecastVisits") private var forecastVisits = 0
    @AppStorage("heatMapVisits") private var heatMapVisits = 0
    @AppStorage("settingsVisits") private var settingsVisits = 0

    // Once we have asked the user to leave a review,
    // we only want to ask again if they have installed a new version.
    @AppStorage("lastReviewedAppVersion") var lastReviewedAppVersion = ""

    // Singleton
    static let shared = AppReview()
    private init() {}

    private let triggerTarget = 3

    private var appVersion: String {
        let infoDict = Bundle.main.infoDictionary!
        let key = "CFBundleShortVersionString"
        return infoDict[key] as? String ?? ""
    }

    private func clearVisits() {
        chartVisits = 0
        currentVisits = 0
        forecastVisits = 0
        heatMapVisits = 0
        settingsVisits = 0
    }

    var haveNewVersion: Bool {
        appVersion != lastReviewedAppVersion
    }

    // For debugging
    func printVisits() {
        print("currentVisits =", currentVisits)
        print("forecastVisits =", forecastVisits)
        print("chartVisits =", chartVisits)
        print("heatMapVisits =", heatMapVisits)
        print("settingsVisits =", settingsVisits)
    }

    // appId is typically a 10-digit number.
    func reviewURL(appId: Int) -> URL? {
        let string = "https://apps.apple.com/app/id\(appId)?action=write-review"
        return URL(string: string)
    }

    var shouldRequest: Bool {
        guard haveNewVersion else {
            clearVisits()
            return false
        }

        // printVisits()
        let target = 3
        let usedEnough =
            chartVisits >= target &&
            currentVisits >= target &&
            forecastVisits >= target &&
            heatMapVisits >= target &&
            settingsVisits >= 1
        // print("usedEnough =", usedEnough)
        if usedEnough {
            lastReviewedAppVersion = appVersion
            clearVisits()
        }
        return usedEnough
    }
}
