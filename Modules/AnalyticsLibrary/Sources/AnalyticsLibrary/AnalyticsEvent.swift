import Foundation

/// Represents the types of analytics events that can be tracked.
///
/// Each event type carries relevant context through associated values,
/// enabling detailed analysis while maintaining type safety.
public enum AnalyticsEvent {
    /// Tracks when a screen is displayed to the user.
    ///
    /// - Parameter name: The screen identifier (e.g., "Accounts", "Goals").
    case screenView(name: String)

    /// Tracks user interactions with UI elements.
    ///
    /// - Parameters:
    ///   - name: The button/action identifier (e.g., "add_to_goal", "create_goal").
    ///   - screen: Screen context where the tap occurred.
    case buttonTap(name: String, screen: String)

    /// Tracks successful round-up transfers to savings goals.
    ///
    /// - Parameters:
    ///   - amount: The round-up amount in minor units (pence).
    ///   - goalName: The name of the goal receiving the transfer.
    case roundUpSaved(amount: Int, goalName: String)

    /// Tracks navigation between screens.
    ///
    /// - Parameters:
    ///   - from: The source screen.
    ///   - to: The destination screen.
    case navigation(from: String, to: String)

    /// Tracks errors encountered during operations.
    ///
    /// - Parameters:
    ///   - type: The error category (e.g., "network", "parsing").
    ///   - message: Brief error description.
    case error(type: String, message: String)

    /// The event name used for tracking.
    var name: String {
        switch self {
        case .screenView: "screen_view"
        case .buttonTap: "button_tap"
        case .roundUpSaved: "round_up_saved"
        case .navigation: "navigation"
        case .error: "error"
        }
    }

    /// The event parameters as a dictionary for analytics providers.
    var parameters: [String: Any] {
        switch self {
        case .screenView(let name):
            ["screen_name": name]

        case .buttonTap(let name, let screen):
            ["button_name": name,
             "screen": screen]

        case .roundUpSaved(let amount, let goalName):
            ["amount": amount,
             "goal_name": goalName]

        case .navigation(let from, let to):
            ["from_screen": from,
             "to_screen": to]

        case .error(let type, let message):
            ["error_type": type,
             "error_message": message]
        }
    }
}
