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
        enum UserCell {
            static func reputation(_ value: String) -> String {
                String(format: "accessibility.userCell.reputation".localized, value)
            }

            static func location(_ value: String) -> String {
                String(format: "accessibility.userCell.location".localized, value)
            }

            static func badges(gold: String, silver: String, bronze: String) -> String {
                String(format: "accessibility.userCell.badges".localized, gold, silver, bronze)
            }

            enum FollowButton {
                static func follow(_ name: String) -> String {
                    String(format: "accessibility.userCell.followButton.follow".localized, name)
                }

                static func following(_ name: String) -> String {
                    String(format: "accessibility.userCell.followButton.following".localized, name)
                }

                static let hint = "accessibility.userCell.followButton.hint".localized
            }
        }
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
