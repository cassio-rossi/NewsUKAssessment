import AnalyticsLibrary
import Foundation
import LoggerLibrary
import NetworkLibrary

final class UsersViewModel {
    // MARK: - Definitions -

    // MARK: - Properties -

    let network: Network
    let logger: LoggerProtocol
    let analytics: AnalyticsProtocol

    var users = [User]()
    var error: ServiceError?

    // MARK: - Init -

    init(network: Network,
         logger: LoggerProtocol,
         analytics: AnalyticsProtocol) {
        self.network = network
        self.logger = logger
        self.analytics = analytics
    }
}

// MARK: - Network Methods -

extension UsersViewModel {
    @MainActor
    func getUsers() async throws {
        let endpoint = UsersEndpoint.users.endpoint(with: network.customHost)
        logger.debug("Fetching users from: \(endpoint.url)")

        do {
            let object: Stackoverflow<User> = try await network.get(url: endpoint.url)
            self.users = object.items
            self.error = nil
            logger.info("Retrieved \(users.count) users(s)")
        } catch let error as ServiceError {
            logger.error("Failed to fetch users: \(error.description)")
            self.error = error
            throw error
        }
    }
}
