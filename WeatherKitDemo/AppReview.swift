import SwiftUI

struct AppReview {
    @AppStorage("lastReviewedAppVersion") var lastReviewedAppVersion = ""
    @AppStorage("triggerCount") var triggerCount = 0
    @Environment(\.requestReview) var realRequestReview

    // Singleton
    static let shared = AppReview()
    private init() {}

    private let triggerTarget = 3

    var appVersion: String {
        let infoDict = Bundle.main.infoDictionary!
        let key = "CFBundleShortVersionString"
        return infoDict[key] as? String ?? ""
    }

    var haveNewVersion: Bool {
        appVersion != lastReviewedAppVersion
    }

    func requestReview() {
        if shouldRequest {
            Task {
                try await Task.sleep(
                    until: .now + .seconds(1),
                    clock: .suspending
                )
                await realRequestReview()
            }
        }
    }

    func reviewURL(appId: Int) -> URL? {
        print("AppReview.reviewURL: appId =", appId)
        let string = "https://apps.apple.com/app/id\(appId)?action=write-review"
        print("AppReview.reviewURL: string =", string)
        return URL(string: string)
    }

    var shouldRequest: Bool {
        guard haveNewVersion else {
            print("no update since last request")
            triggerCount = 0
            return false
        }

        triggerCount += 1
        print("triggerCount: \(triggerCount)")

        if triggerCount >= triggerTarget {
            print("target reached - requesting review")
            lastReviewedAppVersion = appVersion
            print("lastReviewedAppVersion: \(lastReviewedAppVersion)")
            triggerCount = 0
            return true
        }

        print("target not reached")
        return false
    }
}
