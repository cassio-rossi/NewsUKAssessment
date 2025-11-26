@testable import NetworkLibrary
import Foundation
import Testing

@Suite("String Extensions Tests")
struct StringExtensionsTests {

    let date: Date

    init() {
        var components = DateComponents()
        components.day = 10
        components.month = 10
        components.year = 1969
        components.hour = 8
        components.minute = 20
        components.second = 0
        components.timeZone = TimeZone(abbreviation: "GMT")

        self.date = Calendar.current.date(from: components)!
    }

    @Test("Date format with predefined formats")
    func dateFormat() {
        #expect("10/10/1969 08:20".toDate(format: .dateTime) == date)

        let componentsDateOnly = Calendar.current.dateComponents([.year, .month, .day], from: "10/10/1969".toDate(format: .dateOnly))
        #expect(componentsDateOnly.day == 10)
        #expect(componentsDateOnly.month == 10)
        #expect(componentsDateOnly.year == 1969)

        let componentsSortedDate = Calendar.current.dateComponents([.year, .month, .day], from: "19691010".toDate(format: .sortedDate))
        #expect(componentsSortedDate.day == 10)
        #expect(componentsSortedDate.month == 10)
        #expect(componentsSortedDate.year == 1969)

        if let timezone = TimeZone(abbreviation: "GMT") {
            let componentsHourOnly = Calendar.current.dateComponents(in: timezone, from: "08:20".toDate(format: .hourOnly))
            #expect(componentsHourOnly.hour == 8)
            #expect(componentsHourOnly.minute == 20)
        }

        let componentsWeek = Calendar.current.dateComponents([.day, .month], from: "10/Oct".toDate(format: .week))
        #expect(componentsWeek.day == 10)
        #expect(componentsWeek.month == 10)
    }

    @Test("Date format with custom format strings")
    func dateFormatFreeFormat() {
        #expect("10/10/1969 08:20".toDate("dd/MM/yyyy HH:mm") == date)

        let componentsDateOnly = Calendar.current.dateComponents([.year, .month, .day], from: "10/10/1969".toDate("dd/MM/yyyy"))
        #expect(componentsDateOnly.day == 10)
        #expect(componentsDateOnly.month == 10)
        #expect(componentsDateOnly.year == 1969)

        let componentsSortedDate = Calendar.current.dateComponents([.year, .month, .day], from: "19691010".toDate("yyyyMMdd"))
        #expect(componentsSortedDate.day == 10)
        #expect(componentsSortedDate.month == 10)
        #expect(componentsSortedDate.year == 1969)

        if let timezone = TimeZone(abbreviation: "GMT") {
            let componentsHourOnly = Calendar.current.dateComponents(in: timezone, from: "08:20".toDate("HH:mm"))
            #expect(componentsHourOnly.hour == 8)
            #expect(componentsHourOnly.minute == 20)
        }

        let componentsWeek = Calendar.current.dateComponents([.day, .month], from: "10/Oct".toDate("dd/MMM"))
        #expect(componentsWeek.day == 10)
        #expect(componentsWeek.month == 10)
    }
}
