import Foundation

extension String: LocalizedError {
    // Allows String values to be thrown.
    public var errorDescription: String? { self }

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
