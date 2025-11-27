import Foundation

// swiftlint:disable nesting

/// Type-safe localization enum providing access to localized strings
/// Usage: L10n.NetworkError.missingBody
enum L10n {

    // MARK: - Users -

    enum Users {
        static let title = "users.title".localized

        enum Button {
            static let follow = "users.button.follow".localized
            static let following = "users.button.following".localized
        }

        enum Error {
            static let notfound = "users.error.notfound".localized
        }
    }

    // MARK: - Network Errors -

    enum NetworkError {
        static let network = "error.network".localized
        static let networkDetailed = "error.network.detailed".localized
        static let parsing = "error.parsing".localized
        static let missingBody = "error.missingBody".localized
    }

    // MARK: - Accessibility -

    enum Accessibility {
        static let newGoalField = "accessibility.newGoalField".localized
        static let createGoalButton = "accessibility.createGoalButton".localized
        static let previousWeekButton = "accessibility.previousWeekButton".localized
        static let nextWeekButton = "accessibility.nextWeekButton".localized
    }
}

// swiftlint:enable nesting

// MARK: - Localized -

extension String {
    /// Localize a String using the main bundle strings
    var localized: String {
        NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
