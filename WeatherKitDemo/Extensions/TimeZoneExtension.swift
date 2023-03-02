import Foundation

extension TimeZone {
    // Gets current date in time zone of selected location.
    var date: Date {
        let date = Date.current
        return date.hoursAfter(date.timeZoneOffset)
    }

    // Gets the number of hours from GMT to this time zone.
    func hoursFromGMT(for date: Date = Date.current) -> Int {
        let seconds = secondsFromGMT(for: date)
        return seconds / 60 / 60
    }
}
