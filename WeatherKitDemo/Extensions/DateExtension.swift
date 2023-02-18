import Foundation

extension Date {
    static var current: Date {
        #if targetEnvironment(simulator)
            // Use the date/time when the JSON weather data was saved.
            let components = DateComponents(
                year: 2023,
                month: 2,
                day: 17,
                hour: 15,
                minute: 50
            )
            return Calendar.current.date(from: components)!
        #else
            return Date.now
        #endif
    }

    // Returns an abbreviated day of the week (ex. Sun).
    var dayOfWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }

    // Returns 1 for Sunday and 7 for Saturday.
    var dayOfWeekNumber: Int {
        Calendar.current.dateComponents([.weekday], from: self).weekday!
    }

    func daysAfter(_ days: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(
            byAdding: .day,
            value: days,
            to: self
        )!
    }

    func daysBefore(_ days: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(
            byAdding: .day,
            value: -days,
            to: self
        )!
    }

    // Returns a String representation of the Date
    // showing only the hour and AM|PM.
    var h: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a"
        return dateFormatter.string(from: self)
    }

    // Returns the hour of a `Date` in the current time zone.
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }

    func hoursAfter(_ hours: Double) -> Date {
        let calendar = Calendar.current
        return calendar.date(
            byAdding: .minute,
            value: Int(hours * 60),
            to: self
        )!
    }

    func hoursAfter(_ hours: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(
            byAdding: .hour,
            value: hours,
            to: self
        )!
    }

    func hoursBefore(_ hours: Double) -> Date {
        let calendar = Calendar.current
        return calendar.date(
            byAdding: .minute,
            value: -Int(hours * 60),
            to: self
        )!
    }

    func hoursBefore(_ hours: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(
            byAdding: .hour,
            value: -hours,
            to: self
        )!
    }

    // From https://stackoverflow.com/questions/28162729/
    // nsdateformatter-detect-24-hour-clock-in-os-x-and-ios
    static func is24Hour() -> Bool {
        let dateFormat = DateFormatter.dateFormat(
            fromTemplate: "j",
            options: 0,
            locale: Locale.current
        )!
        return dateFormat.firstIndex(of: "a") == nil
    }

    // Returns a String representation of the Date in "M/d" format.
    var md: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        return dateFormatter.string(from: self)
    }

    var nextHour: Date { removeSeconds().hoursAfter(1) }

    func removeSeconds() -> Date {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour], // not seconds or nanoseconds
            from: self
        )
        return Calendar.current.date(from: components)!
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var timeZoneOffset: Double {
        let currentSeconds = TimeZone.current.secondsFromGMT(for: self)
        let locationVM = LocationViewModel.shared
        let targetSeconds = locationVM.timeZone?.secondsFromGMT(for: self)
        guard let targetSeconds else { return 0 }
        return Double(targetSeconds - currentSeconds) / 60.0 / 60.0
    }

    var tomorrow: Date {
        let begin = startOfDay
        return Calendar.current.date(byAdding: .day, value: 1, to: begin)!
    }

    var yesterday: Date {
        let begin = startOfDay
        return Calendar.current.date(byAdding: .day, value: -1, to: begin)!
    }
}
