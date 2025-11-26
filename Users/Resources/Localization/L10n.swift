import Foundation

// swiftlint:disable nesting

/// Type-safe localization enum providing access to localized strings
/// Usage: L10n.NetworkError.missingBody
enum L10n {

    // MARK: - General -

    enum General {
        static let all = "general.all".localized
        static let create = "general.create".localized
        static let cancel = "general.cancel".localized
    }

    // MARK: - Accounts -

    enum Accounts {
        enum Segmented {
            static let all = "accounts.segmented.all".localized
            static let `in` = "accounts.segmented.in".localized
            static let out = "accounts.segmented.out".localized
        }

        enum Roundup {
            static let label = "accounts.roundup.label".localized
        }

        enum Button {
            static let addToGoal = "accounts.button.addToGoal".localized
        }

        enum Error {
            static let noTransactions = "accounts.error.noTransactions".localized
            static func reason(_ reason: String) -> String {
                String(format: "accounts.error.reason".localized, reason)
            }
        }
    }

    // MARK: - Goals -

    enum Goals {
        static let title = "goals.title".localized

        enum TextField {
            static let placeholder = "goals.textfield.placeholder".localized
        }

        enum Button {
            static let create = "goals.button.create".localized
        }

        enum Label {
            static let selectGoal = "goals.label.selectGoal".localized
            static func amountAvailable(_ amount: String) -> String {
                String(format: "goals.label.amountAvailable".localized, amount)
            }
        }

        enum Error {
            static let cannotProceed = "goals.error.cannotProceed".localized
            static let enterName = "goals.error.enterName".localized
        }

        enum Empty {
            static let message = "goals.empty.message".localized
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
