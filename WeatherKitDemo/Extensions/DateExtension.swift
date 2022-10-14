import Foundation

extension Date {
    func removeSeconds() -> Date {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour], // not seconds or nanoseconds
            from: self
        )
        return Calendar.current.date(from: components)!
    }
}
