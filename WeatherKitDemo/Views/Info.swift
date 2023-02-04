import SwiftUI

struct Info: View {
    let appInfo: AppInfo?

    init(appInfo: AppInfo?) {
        self.appInfo = appInfo
    }

    var body: some View {
        VStack(spacing: 20) {
            if let appInfo {
                Text(appInfo.name).font(.headline)
                AsyncImage(
                    url: URL(string: appInfo.iconURL),
                    content: { image in image.resizable() },
                    placeholder: { ProgressView() } // spinner
                )
                .frame(width: 100, height: 100)
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
        }
        .padding()
    }
}
