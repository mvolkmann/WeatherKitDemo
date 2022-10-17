import Foundation

extension Date {
    // Returns a String representation of the Date
    // showing only the hour and AM|PM.
    var h: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        return dateFormatter.string(from: self)
    }

    // Returns a String representation of the Date in "M/d" format.
    var md: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        return dateFormatter.string(from: self)
    }

    func removeSeconds() -> Date {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour], // not seconds or nanoseconds
            from: self
        )
        return Calendar.current.date(from: components)!
    }
}
