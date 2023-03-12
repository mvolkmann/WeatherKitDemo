import SwiftUI

// This is a custom view modifier that detects when the device has been rotated.
// See the "Hacking With Swift" page
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-device-rotation
struct DeviceRotationViewModifier: ViewModifier {
    #if os(iOS)
        let action: (UIDeviceOrientation) -> Void
    #endif

    func body(content: Content) -> some View {
        content
            .onAppear()
        #if os(iOS)
            .onReceive(
                NotificationCenter.default
                    .publisher(
                        for: UIDevice.orientationDidChangeNotification
                    )
            ) { _ in
                action(UIDevice.current.orientation)
            }
        #endif
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

    /// Supports conditional view modifiers.
    /// For example, .if(price > 100) { view in view.background(.orange) }
    /// The concrete type of Content can be any type
    /// that conforms to the View protocol.
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        // This cannot be replaced by a ternary expression.
        if condition {
            transform(self)
        } else {
            self
        }
    }

    #if os(iOS)
        func onRotate(
            perform action: @escaping (UIDeviceOrientation) -> Void
        ) -> some View {
            modifier(DeviceRotationViewModifier(action: action))
        }
    #endif
}
