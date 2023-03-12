import UIKit

#if os(iOS)
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(
            _ application: UIApplication,
            supportedInterfaceOrientationsFor window: UIWindow?
        ) -> UIInterfaceOrientationMask {
            // Lock the orientation to portrait.
            return UIInterfaceOrientationMask.portrait
        }
    }
#endif
