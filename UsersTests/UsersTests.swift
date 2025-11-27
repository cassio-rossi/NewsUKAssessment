import AnalyticsLibrary
import Foundation
import LoggerLibrary
import NetworkLibrary
import Testing
@testable import Users

final class BundleTestUsersViewModel {}

@Suite("UsersViewModel")
struct UsersViewModelTests {

    // MARK: - Test Helpers -

    @MainActor
    private func createMockFollowService() -> FollowService {
        return FollowService(storage: MockStorage())
    }

    // MARK: - Network Request Tests -

    @Test
    @MainActor
    func testGetUsersSuccess() async throws {
        // Mock JSON files are now in the test bundle
        let mapper = [
            NetworkMockData(api: "/users", filename: "users", bundlePath: Bundle(for: BundleTestUsersViewModel.self).bundlePath)
        ]
        let service = NetworkServicesMock(
            customHost: CustomHost(host: "test.local"),
            mapper: mapper
        )
        let viewModel = UsersViewModel(
            network: Network(service: service),
            logger: Logger(category: "UsersViewModelTests"),
            analytics: Analytics(),
            followService: createMockFollowService(),
            imageLoader: ImageLoader()
        )

        try await viewModel.getUsers()
        #expect(viewModel.users.count == 2)
        #expect(viewModel.users.first?.displayName == "Jon Skeet")
        #expect(viewModel.error == nil)
    }

    @Test
    @MainActor
    func testGetUsersNetworkFailure() async {
        let viewModel = UsersViewModel(
            network: Network(service: NetworkServicesFailed(
                customHost: CustomHost(host: "test.local")
            )),
            logger: Logger(category: "UsersViewModelTests"),
            analytics: Analytics(),
            followService: createMockFollowService(),
            imageLoader: ImageLoader()
        )

        do {
            try await viewModel.getUsers()
            Issue.record("Should have thrown an error")
        } catch {
            #expect(viewModel.error != nil)
        }
    }

    @Test
    @MainActor
    func testGetUsersFailed() async throws {
        // Mock JSON files are now in the test bundle
        let mapper = [
            NetworkMockData(api: "/users", filename: "error", bundlePath: Bundle(for: BundleTestUsersViewModel.self).bundlePath)
        ]
        let service = NetworkServicesMock(
            customHost: CustomHost(host: "test.local"),
            mapper: mapper
        )
        let viewModel = UsersViewModel(
            network: Network(service: service),
            logger: Logger(category: "UsersViewModelTests"),
            analytics: Analytics(),
            followService: createMockFollowService(),
            imageLoader: ImageLoader()
        )

        do {
            try await viewModel.getUsers()
        } catch {
            #expect(Bool(viewModel.users.isEmpty))

            switch viewModel.error {
            case let .error(reason):
                #expect(reason.error == "400")
                #expect(reason.errorDescription == "bad_parameter")
            default:
                Issue.record("Should have an error object")
            }
        }
    }

    // MARK: - Follow Tests -

    @Test
    @MainActor
    func testIsFollowingUser() {
        let mockStorage = MockStorage()
        let mockFollowService = FollowService(storage: mockStorage)
        let viewModel = UsersViewModel(
            network: Network(service: NetworkServicesFailed(customHost: CustomHost(host: "test.local"))),
            logger: Logger(category: "UsersViewModelTests"),
            analytics: Analytics(),
            followService: mockFollowService,
            imageLoader: ImageLoader()
        )

        let userId = 123
        #expect(!viewModel.isFollowing(userId: userId))

        mockFollowService.follow(userId: userId)
        #expect(viewModel.isFollowing(userId: userId))
    }

    @Test
    @MainActor
    func testToggleFollowUser() {
        let mockStorage = MockStorage()
        let mockFollowService = FollowService(storage: mockStorage)
        let viewModel = UsersViewModel(
            network: Network(service: NetworkServicesFailed(customHost: CustomHost(host: "test.local"))),
            logger: Logger(category: "UsersViewModelTests"),
            analytics: Analytics(),
            followService: mockFollowService,
            imageLoader: ImageLoader()
        )

        let userId = 456

        // Initially not following
        #expect(!viewModel.isFollowing(userId: userId))

        // Toggle to follow
        viewModel.toggleFollow(userId: userId)
        #expect(viewModel.isFollowing(userId: userId))

        // Toggle to unfollow
        viewModel.toggleFollow(userId: userId)
        #expect(!viewModel.isFollowing(userId: userId))
    }
}
