import Foundation

public enum Format {
    static let web = "yyyy-MM-dd'T'HH:mm:ss'Z'"
}

// MARK: - Dates -

extension String {
	/// Format a String into a Date using a specific format, locale and timezone
	///
	/// - Parameter using: The desired format
	/// - Parameter locale: `optional` The Locale to be used to format the date. Default `en_US`
	/// - Parameter timezone: `optional` The timezone to format the date. Default `UTC`
	/// - Returns a formatted date
	public func toDate(_ format: String? = nil,
					   locale: String = "en_US",
					   timeZone: TimeZone? = TimeZone(abbreviation: "UTC")) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: locale)
        dateFormatter.timeZone = timeZone
		dateFormatter.dateFormat = format ?? Format.web
		return dateFormatter.date(from: self.replacingOccurrences(of: ".000", with: "")) ?? Date()
    }

	/// Format a String into a Date using an optional format
	///
	/// - Parameter using: `optional` The desired DateFormat. Default `.dateOnly`
	/// - Returns a formatted date
	public func toDate(format: DateFormat = .dateOnly) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: self) ?? Date()
    }
}

// MARK: - Localized -

extension String {
	/// Localize a String using the local bundle strings
	var localized: String {
		NSLocalizedString(self, tableName: nil, bundle: Bundle.module, value: "", comment: "")
	}
}

// MARK: - Data -

extension String {
	public var asData: Data { Data(self.utf8) }
}
