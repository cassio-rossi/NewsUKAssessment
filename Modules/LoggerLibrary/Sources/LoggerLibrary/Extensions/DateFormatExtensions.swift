import Foundation

/// Predefined date format patterns.
enum DateFormat: String {
    /// Date and time format: "dd/MM/yyyy HH:mm"
    case dateTime = "dd/MM/yyyy HH:mm"
}

extension Date {
    /// Formats the date using a predefined format.
    ///
    /// - Parameter format: The ``DateFormat`` to use. Defaults to ``DateFormat/dateOnly``.
    /// - Returns: The formatted date string.
    func format(using format: DateFormat = .dateTime) -> String {
        self.format(using: format.rawValue)
	}

    /// Formats the date using a custom format string.
    ///
    /// - Parameters:
    ///   - format: The date format string.
    ///   - locale: The locale for formatting. Defaults to system locale.
    ///   - timezone: The timezone for formatting. Defaults to BRT.
    /// - Returns: The formatted date string.
	func format(using format: String, locale: Locale? = nil, timezone: TimeZone? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timezone ?? TimeZone(abbreviation: "BRT")
        if let locale {
            dateFormatter.locale = locale
        }
        return dateFormatter.string(from: self)
    }
}
