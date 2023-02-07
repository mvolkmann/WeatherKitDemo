import Foundation

extension TimeZone {
    // Gets the current date in this time zone.
    var date: Date {
        let currentOffset = TimeZone.current.hoursFromGMT(for: Date.now)
        let thisOffset = hoursFromGMT(for: Date.now)
        return Date.now.hoursAfter(thisOffset - currentOffset)
    }

    // Gets the number of hours from GMT to this time zone.
    func hoursFromGMT(for date: Date = Date.now) -> Int {
        let seconds = secondsFromGMT(for: date)
        return seconds / 60 / 60
    }
}
