@testable import NetworkLibrary
import Foundation
import Testing

@Suite("Date Extensions Tests")
struct DateExtensionsTests {

    let date: Date

    init() {
        var components = DateComponents()
        components.day = 10
        components.month = 10
        components.year = 1969
        components.hour = 8
        components.minute = 20
        components.second = 50
        components.timeZone = TimeZone(abbreviation: "BRT")

        self.date = Calendar.current.date(from: components)!
    }

    @Test("Format date using dateOnly format")
    func dateFormat() {
        let value = date.format(using: .dateOnly)
        #expect(value == "10/10/1969")
    }

    @Test("Date format should not match incorrect format")
    func dateFormatFailed() {
        let value = date.format(using: .dateOnly)
        #expect(value != "19691010")
    }

    @Test("Date format should not match incorrect date")
    func dateFormatFailedDate() {
        let value = date.format(using: .dateOnly)
        #expect(value != "19/10/1969")
    }

    @Test("Format date using sortedDate format")
    func sortFormat() {
        let value = date.format(using: .sortedDate)
        #expect(value == "19691010")
    }

    @Test("Sorted date format should not match incorrect format")
    func sortFormatFailed() {
        let value = date.format(using: .sortedDate)
        #expect(value != "1969/10/10")
    }

    @Test("Format date using dateTime format")
    func dateTimeFormat() {
        let value = date.format(using: .dateTime)
        #expect(value == "10/10/1969 11:20")
    }

    @Test("DateTime format should not match incorrect time")
    func dateTimeFormatFailed() {
        let value = date.format(using: .dateTime)
        #expect(value != "10/10/1969 04:20")
    }

    @Test("DateTime format handles timezone correctly")
    func dateTimeFormatTimezone() {
        var components = DateComponents()
        components.day = 10
        components.month = 10
        components.year = 1969
        components.hour = 8
        components.minute = 20
        components.second = 50
        components.timeZone = TimeZone(abbreviation: "GMT")

        let gmtDate = Calendar.current.date(from: components)!

        let value = gmtDate.format(using: .dateTime)
        #expect(value == "10/10/1969 08:20")
    }

    @Test("Date format roundtrip using enum formatter")
    func dateFormatUsingEnumFormatter() {
        let value = date.format(using: .sortedDate)
        #expect(value == "19691010")

        var components = DateComponents()
        components.day = 10
        components.month = 10
        components.year = 1969
        components.timeZone = TimeZone(abbreviation: "GMT")

        let expectedDate = Calendar.current.date(from: components)

        let formattedDate = value.toDate(format: .sortedDate)
        #expect(expectedDate == formattedDate)
    }
}
