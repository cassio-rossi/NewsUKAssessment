import AnalyticsLibrary
import Foundation
import LoggerLibrary
import NetworkLibrary
import Testing
@testable import Users

final class BundleTestUsersViewModel {}

@Suite("UsersViewModel")
struct UsersViewModelTests {

    // MARK: - Network Request Tests -

    @Test
    @MainActor
    func testGetUsersSuccess() async throws {
        // Mock JSON files are now in the test bundle
        let service = NetworkServicesMock(
            bundle: Bundle(for: BundleTestUsersViewModel.self),
            mapper: ["/users": "users"]
        )
        let viewModel = UsersViewModel(
            network: Network(
                service: service,
                bearer: nil,
                customHost: CustomHost(host: "test.local", path: "")
            ),
            logger: Logger(category: "UsersViewModelTests"),
            analytics: Analytics()
        )

        try await viewModel.getUsers()
        #expect(viewModel.users.count == 2)
        #expect(viewModel.users.first?.displayName == "Jon Skeet")
        #expect(viewModel.error == nil)
    }

    @Test
    @MainActor
    func testGetAccountsFailure() async {
        let viewModel = UsersViewModel(
            network: Network(
                service: NetworkServicesFailed(),
                bearer: "",
                customHost: CustomHost(host: "test.local", path: "/2.2")
            ),
            logger: Logger(category: "UsersViewModelTests"),
            analytics: Analytics()
        )

        do {
            try await viewModel.getUsers()
            Issue.record("Should have thrown an error")
        } catch {
            #expect(viewModel.error != nil)
        }
    }
}
