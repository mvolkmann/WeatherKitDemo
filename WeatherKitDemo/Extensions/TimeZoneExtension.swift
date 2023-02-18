import Foundation

extension TimeZone {
    // Gets the current date in this time zone.
    var date: Date {
        let date = Date.current
        let currentOffset = TimeZone.current.hoursFromGMT(for: date)
        let thisOffset = hoursFromGMT(for: date)
        return date.hoursAfter(thisOffset - currentOffset)
    }

    // Gets the number of hours from GMT to this time zone.
    func hoursFromGMT(for date: Date = Date.current) -> Int {
        let seconds = secondsFromGMT(for: date)
        return seconds / 60 / 60
    }
}
