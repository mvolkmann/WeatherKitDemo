import SwiftUI

struct Toggle2: View {
    let off: String
    let on: String
    @Binding var isOn: Bool

    var body: some View {
        Picker("Title Goes Here", selection: $isOn) {
            Text(off.localized).tag(false)
            Text(on.localized).tag(true)
        }
        .pickerStyle(.segmented)
        .font(.callout)
    }
}
