import SwiftUI

// Inspired by https://www.hackingwithswift.com/quick-start/swiftui/
// how-to-automatically-switch-between-hstack-and-vstack-based-on-size-class
// This isn't currently being used, but I may need it in another project.
struct Stack<Content: View>: View {
    let vertical: Bool
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    init(
        vertical: Bool,
        horizontalAlignment: HorizontalAlignment = .leading,
        verticalAlignment: VerticalAlignment = .top,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.vertical = vertical
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        Group {
            if vertical {
                VStack(
                    alignment: horizontalAlignment,
                    spacing: spacing,
                    content: content
                )
            } else {
                HStack(
                    alignment: verticalAlignment,
                    spacing: spacing,
                    content: content
                )
            }
        }
    }
}
