import AnalyticsLibrary
import Foundation
import LoggerLibrary
import NetworkLibrary

/// Manages application-wide service instances
final class DependencyContainer {

    // MARK: - Shared Instance -

    /// Default container for production use
    /// Tests should create their own container with mocks
    static let `default` = DependencyContainer()

    // MARK: - Services -

    /// App configuration
    let config: AppConfiguration

    /// Network service
    let networkServices: NetworkServicesProtocol

    /// Storage service for persisting data
    let storage: StorageProtocol

    /// Follow service for managing followed users
    let followService: FollowServiceProtocol

    /// Logger for application-wide logging
    let logger: LoggerProtocol?

    /// Analytics for tracking user behavior
    let analytics: AnalyticsProtocol

    // MARK: - Initialization -

    init(config: AppConfiguration = DefaultConfiguration(),
         networkServices: NetworkServicesProtocol? = nil,
         storage: StorageProtocol? = nil,
         followService: FollowServiceProtocol? = nil,
         logger: LoggerProtocol? = nil,
         analytics: AnalyticsProtocol? = nil) {

        // Check for UI testing and create test-specific UserDefaults
        let userDefaults: UserDefaults = {
            if let suiteName = ProcessInfo.processInfo.environment["UI_TEST_SUITE"] {
                UserDefaults(suiteName: suiteName) ?? .standard
            } else {
                .standard
            }
        }()

        // Create core services
        self.config = config
        self.networkServices = Self.makeNetworkServices(host: config.customHost)
        self.storage = storage ?? StorageService(userDefaults: userDefaults)
        self.logger = logger
        self.analytics = analytics ?? Analytics()

        // Create follow service with dependencies
        self.followService = followService ?? FollowService(
            storage: self.storage,
            logger: logger
        )
    }
}

private extension DependencyContainer {
    // When doing UI tests, we need to mock the ViewModel to load local data otherwise
    static func makeNetworkServices(host: CustomHost) -> NetworkServicesProtocol {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("mock"),
           let environment = ProcessInfo.processInfo.environment["mapper"],
           let data = environment.asBase64data,
           let mapper: [NetworkMockData] = data.asObject() {

            return NetworkServicesMock(customHost: host, mapper: mapper)
        } else {
            return NetworkServices(customHost: host)
        }
#else
        return NetworkServices(customHost: host)
#endif
    }
}
