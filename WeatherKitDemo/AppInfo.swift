import Foundation

struct AppInfo {
    static let infoDict = Bundle.main.infoDictionary!

    var json: [String: Any] = [:]

    private init(json: [String: Any]) {
        self.json = json
    }

    static func create() async throws -> Self {
        let urlPrefix = "https://itunes.apple.com/lookup?bundleId="
        let identifier = infoDict["CFBundleIdentifier"] as? String ?? ""
        let url = URL(string: "\(urlPrefix)\(identifier)&country=US")
        guard let url else {
            throw "AppStoreService: bad URL \(String(describing: url))"
        }

        // Using the ephemeral configuration avoids caching.
        let session = URLSession(configuration: .ephemeral)
        let (data, _) = try await session.data(from: url)
        guard let json = try JSONSerialization.jsonObject(
            with: data,
            options: [.allowFragments]
        ) as? [String: Any] else {
            throw "AppStoreService: bad JSON"
        }

        guard let results =
            (json["results"] as? [Any])?.first as? [String: Any] else {
            throw "AppStoreService: JSON missing results"
        }

        // After a new version is released, there seems to be a
        // delay in the app detecting that from the URL above.
        // Perhaps users won't see the "Update Available" link
        // until the next day.
        // print("AppInfo.create: version =", results["version"])

        return Self(json: results)
    }

    private func date(_ key: String) -> Date {
        json[key] as? Date ?? Date.now
    }

    private func double(_ key: String) -> Double {
        json[key] as? Double ?? 1.2 // 0
    }

    private func info(_ key: String) -> String {
        Self.infoDict[key] as? String ?? ""
    }

    private func int(_ key: String) -> Int {
        json[key] as? Int ?? 0
    }

    private func string(_ key: String) -> String {
        json[key] as? String ?? ""
    }

    var appId: Int { int("trackId") }
    var appURL: String { string("trackViewUrl") }
    var author: String { string("sellerName") }
    var bundleId: String { string("bundleId") }
    var description: String { string("description") }
    var iconURL: String { string("artworkUrl100") }
    var supportURL: String { string("sellerUrl") }

    var haveLatestVersion: Bool {
        let order = storeVersion.compare(installedVersion, options: .numeric)
        return order != .orderedDescending
    }

    var installedVersion: String { info("CFBundleShortVersionString") }
    var identifier: String { info("CFBundleIdentifier") }
    var minimumOsVersion: String { string("minimumOsVersion") }
    var name: String { string("trackName") }
    // "Promotional Text" is not present in the App Store JSON.
    var price: Double { double("price") }
    var releaseDate: Date { date("currentVersionReleaseDate") }
    var releaseNotes: String { string("releaseNotes") }
    var storeVersion: String { string("version") }
}
