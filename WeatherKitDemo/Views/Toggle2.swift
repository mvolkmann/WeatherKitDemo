import SwiftUI

struct Toggle2: View {
    let off: String
    let on: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(off.localized).onTapGesture { isOn = false }
            Toggle("", isOn: $isOn).labelsHidden()
            Text(on.localized).onTapGesture { isOn = true }
        }
    }
}
