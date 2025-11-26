import AnalyticsLibrary
import Foundation
import LoggerLibrary

/// Manages application-wide service instances
final class DependencyContainer {
    // MARK: - Shared Instance -

    /// Default container for production use
    /// Tests should create their own container with mocks
    static let `default` = DependencyContainer()

    // MARK: - Services -

    /// Storage service for persisting data
    let storage: StorageProtocol

    /// Follow service for managing followed users
    let followService: FollowServiceProtocol

    /// Logger for application-wide logging
    let logger: LoggerProtocol

    /// Analytics for tracking user behavior
    let analytics: AnalyticsProtocol

    // MARK: - Initialization -

    init(storage: StorageProtocol? = nil,
         followService: FollowServiceProtocol? = nil,
         logger: LoggerProtocol? = nil,
         analytics: AnalyticsProtocol? = nil) {

        // Create core services
        self.storage = storage ?? StorageService()
        self.logger = logger ?? Logger(category: "Users")
        self.analytics = analytics ?? Analytics()

        // Create follow service with dependencies
        self.followService = followService ?? FollowService(
            storage: self.storage,
            logger: Logger(category: "FollowService")
        )
    }
}

// MARK: - Test Helpers -

#if DEBUG
extension DependencyContainer {
    /// Creates a container with mock dependencies for testing
    static func mock(storage: StorageProtocol,
                     followService: FollowServiceProtocol? = nil,
                     logger: LoggerProtocol? = nil,
                     analytics: AnalyticsProtocol? = nil) -> DependencyContainer {
        return DependencyContainer(
            storage: storage,
            followService: followService,
            logger: logger,
            analytics: analytics
        )
    }
}
#endif
