import Foundation

extension TimeZone {
    // Gets current date in time zone of selected location.
    var date: Date {
        let date = Date.current
        return date.hoursAfter(date.timeZoneOffset)
    }
}
