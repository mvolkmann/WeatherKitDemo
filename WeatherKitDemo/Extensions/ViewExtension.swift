import SwiftUI

// This is a custom view modifier that detects when the device has been rotated.
// See the "Hacking With Swift" page
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-device-rotation
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(
                NotificationCenter.default
                    .publisher(
                        for: UIDevice.orientationDidChangeNotification
                    )
            ) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    #if os(iOS)
        @available(iOSApplicationExtension, unavailable)
        func dismissKeyboard() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    #endif

    func onRotate(
        perform action: @escaping (UIDeviceOrientation) -> Void
    ) -> some View {
        modifier(DeviceRotationViewModifier(action: action))
    }
}
