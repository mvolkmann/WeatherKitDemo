import Foundation

extension TimeZone {
    // Gets the current date in this time zone.
    var date: Date {
        let now = Date() // in current time zone
        let currentOffset = TimeZone.current.hoursFromGMT(for: now)
        let thisOffset = hoursFromGMT(for: now)
        return now.hoursAfter(thisOffset - currentOffset)
    }

    // Gets the number of hours from GMT to this time zone.
    func hoursFromGMT(for date: Date = Date()) -> Int {
        let seconds = secondsFromGMT(for: date)
        return seconds / 60 / 60
    }
}
