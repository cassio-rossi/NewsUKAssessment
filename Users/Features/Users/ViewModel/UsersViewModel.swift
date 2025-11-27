import AnalyticsLibrary
import Foundation
import LoggerLibrary
import NetworkLibrary

final class UsersViewModel {
    // MARK: - Definitions -

    // MARK: - Properties -

    let network: Network
    let logger: LoggerProtocol?
    let analytics: AnalyticsProtocol
    let followService: FollowServiceProtocol

    var users = [User]()
    var error: ServiceError?

    // MARK: - Init -

    init(network: Network,
         logger: LoggerProtocol?,
         analytics: AnalyticsProtocol,
         followService: FollowServiceProtocol) {
        self.network = network
        self.logger = logger
        self.analytics = analytics
        self.followService = followService
    }
}

// MARK: - Network Methods -

extension UsersViewModel {
    @MainActor
    func getUsers() async throws {
        let endpoint = UsersEndpoint.users.endpoint(with: network.service.customHost)
        logger?.debug("Fetching users from: \(endpoint.url)")

        do {
            self.users = try await network.get(url: endpoint.url)
            self.error = nil
            logger?.info("Retrieved \(users.count) users(s)")
        } catch let error as ServiceError {
            logger?.error("Failed to fetch users: \(error.description)")
            self.error = error
            throw error
        }
    }
}

// MARK: - Follow Methods -

extension UsersViewModel {
    func isFollowing(userId: Int) -> Bool {
        return followService.isFollowing(userId: userId)
    }

    func toggleFollow(userId: Int) {
        followService.toggleFollow(userId: userId)
        let isFollowing = followService.isFollowing(userId: userId)
        analytics.track(.buttonTap(
            name: isFollowing ? "follow_user" : "unfollow_user",
            screen: "Users"
        ))
        logger?.debug("User \(userId) follow status: \(isFollowing)")
    }
}
