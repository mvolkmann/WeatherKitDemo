import SwiftUI

@main
struct WeatherKitDemoApp: App {
    #if os(iOS)
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ErrorViewModel())
        }
    }
}
