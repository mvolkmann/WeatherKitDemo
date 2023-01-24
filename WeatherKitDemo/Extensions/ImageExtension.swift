import SwiftUI

extension Image {
    static func symbol(symbolName: String, size: Double = 30) -> some View {
        Image(systemName: symbolName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: size)
    }
}
