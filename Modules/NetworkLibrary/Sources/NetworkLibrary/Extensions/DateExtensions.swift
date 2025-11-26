import Foundation

public enum DateFormat: String {
	case web = "yyyy-MM-dd'T00:00:00.000Z'"
    case dateOnly = "dd/MM/yyyy"
    case sortedDate = "yyyyMMdd"
    case dateTime = "dd/MM/yyyy HH:mm"
    case hourOnly = "HH:mm"
	case week = "dd/MMM"
}

extension Date {
	/// Format Date into a String using an optional format
	///
	/// - Parameter using: `optional` The desired DateFormat. Default `.dateOnly`
	/// - Returns a date formatted string
    public func format(using format: DateFormat = .dateOnly) -> String {
        self.format(using: format.rawValue)
	}

	/// Format Date into a String using a specific format, locale and timezone
	///
	/// - Parameter using: The desired format
	/// - Parameter locale: `optional` The Locale to be used to format the date.
	/// - Parameter timezone: `optional` The timezone to format the date. Default `UTC`
	/// - Returns a date formatted string
	public func format(using format: String, locale: Locale? = nil, timezone: TimeZone? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timezone ?? TimeZone(abbreviation: "UTC")
        if let locale {
            dateFormatter.locale = locale
        }
        return dateFormatter.string(from: self)
    }
}
