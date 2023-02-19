import SwiftUI

struct Info: View {
    let appInfo: AppInfo?

    init(appInfo: AppInfo?) {
        self.appInfo = appInfo
    }

    private var appIcon: UIImage? {
        guard let infoDict = Bundle.main.infoDictionary,
              let icons = infoDict["CFBundleIcons"] as? [String: Any],
              let primaryIcons = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcons["CFBundleIconFiles"] as? [String],
              let icon = iconFiles.first else { return nil }
        return UIImage(named: icon)
    }

    var body: some View {
        VStack(spacing: 20) {
            if let appInfo {
                let title = appInfo.name + " " + appInfo.installedVersion
                Text(title)
                    .accessibilityIdentifier("info-title")
                    .font(.headline)
                // Image("AppIcon") // doesn't work
                if let appIcon {
                    Image(uiImage: appIcon)
                        .resizable()
                        .frame(width: 100, height: 100)
                }
                Text("Created by R. Mark Volkmann")
            } else {
                Text("Failed to access AppInfo.")
            }

            Text("""
            This app was originally created to learn about WeatherKit. \
            It was then expanded to learn about Swift Charts. \
            Now it is a useful app, not just a learning exercise.
            """)
            .lineLimit(5)
            Link(
                "GitHub repository",
                destination: URL(
                    string: "https://github.com/mvolkmann/WeatherKitDemo"
                )!
            )

            let appReview = AppReview.shared
            if !appReview.haveNewVersion {
                // This only works on a real device, not in the Simulator.
                if let appInfo, let appId = appInfo.appId,
                   let url = appReview.reviewURL(appId: appId) {
                    Link(destination: url) {
                        Text("Write a Review")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
    }
}
