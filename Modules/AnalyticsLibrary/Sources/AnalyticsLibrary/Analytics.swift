import Foundation
import LoggerLibrary

/// Default analytics implementation with console logging.
///
/// This implementation provides a foundation for analytics tracking that can be
/// easily extended or replaced with a real analytics provider (Firebase, Mixpanel, etc.).
///
/// In production, this class would integrate with your chosen analytics SDK.
/// For now, it logs events to the console for debugging and verification.
///
/// ```swift
/// let analytics = Analytics()
/// analytics.track(.screenView(name: "Accounts"))
/// analytics.track(.buttonTap(name: "add_to_goal", screen: "Accounts"))
/// analytics.track(.roundUpSaved(amount: 125, goalName: "Holiday Fund"))
/// ```
///
/// ## Topics
///
/// ### Creating an Analytics Instance
/// - ``init(isEnabled:)``
///
/// ### Configuration
/// - ``isEnabled``
///
/// ### Tracking Events
/// - ``track(_:)``
public final class Analytics: AnalyticsProtocol {

    // MARK: - Properties -

    /// Controls whether analytics events are tracked.
    ///
    /// Set to `false` to disable analytics tracking entirely.
    /// Useful for testing, debugging, or user privacy preferences.
    public var isEnabled: Bool

    private let logger: LoggerProtocol?

    // MARK: - Initialization -

    /// Creates an analytics instance.
    ///
    /// - Parameter isEnabled: Whether analytics tracking is enabled. Defaults to `true`.
    public init(isEnabled: Bool = true,
                logger: LoggerProtocol? = nil) {
        self.isEnabled = isEnabled
        self.logger = logger
    }

    // MARK: - Public Methods -

    /// Records an analytics event.
    ///
    /// Events are logged to the console in debug builds and would be sent
    /// to your analytics provider in a production implementation.
    ///
    /// - Parameter event: The event to track with its associated data.
    public func track(_ event: AnalyticsEvent) {
        guard isEnabled else { return }

        let eventData = formatEventData(event)

        logger?.info("📊 [\(event.name)] \(eventData)")

        // In production, send to analytics provider:
        // - Firebase: Analytics.logEvent(event.name, parameters: event.parameters)
        // - Mixpanel: Mixpanel.mainInstance().track(event: event.name, properties: event.parameters)
        // - Custom backend: POST /analytics/events with event data
    }

    // MARK: - Private Helpers -

    /// Formats event parameters as a readable string for console output.
    private func formatEventData(_ event: AnalyticsEvent) -> String {
        let params = event.parameters
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")

        return params.isEmpty ? "no parameters" : params
    }
}
