import SwiftUI

struct AppReview {
    @AppStorage("chartVisits") private var chartVisits = 0
    @AppStorage("currentVisits") private var currentVisits = 0
    @AppStorage("forecastVisits") private var forecastVisits = 0
    @AppStorage("heatMapVisits") private var heatMapVisits = 0
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

    var haveNewVersion: Bool {
        appVersion != lastReviewedAppVersion
    }

    func reviewURL(appId: Int) -> URL? {
        print("AppReview.reviewURL: appId =", appId)
        let string = "https://apps.apple.com/app/id\(appId)?action=write-review"
        print("AppReview.reviewURL: string =", string)
        return URL(string: string)
    }

    var shouldRequest: Bool {
        guard haveNewVersion else {
            print("no app update since last request")
            clearVisits()
            return false
        }

        printVisits()
        let target = 3
        let usedEnough =
            chartVisits >= target &&
            currentVisits >= target &&
            forecastVisits >= target &&
            heatMapVisits >= target
        print("usedEnough =", usedEnough)
        if usedEnough {
            lastReviewedAppVersion = appVersion
            clearVisits()
        }
        return usedEnough
    }

    private func clearVisits() {
        chartVisits = 0
        currentVisits = 0
        forecastVisits = 0
        heatMapVisits = 0
    }

    func printVisits() {
        print("currentVisits =", currentVisits)
        print("forecastVisits =", forecastVisits)
        print("chartVisits =", chartVisits)
        print("heatMapVisits =", heatMapVisits)
    }
}
