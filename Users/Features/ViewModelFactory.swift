import AnalyticsLibrary
import Foundation
import LoggerLibrary
import NetworkLibrary

struct ViewModelFactory {
	/// Default configuration - can be overridden for different environments
	/// In a production app, this might come from dependency injection container
	static var configuration: AppConfiguration = DefaultConfiguration()

#if DEBUG
	static var usersViewModel: UsersViewModel {
        loadMockViewModel() ?? loadViewModel(with: configuration)
	}
#else
	static var usersViewModel: UsersViewModel {
		loadViewModel(with: configuration)
	}
#endif
}

extension ViewModelFactory {
	/// Creates a ViewModel with injected configuration
	/// - Parameter config: The configuration containing auth token, certificates, and API host
	/// - Returns: Configured UsersViewModel ready for production use
	fileprivate static func loadViewModel(with config: AppConfiguration) -> UsersViewModel {
		// Initialize NetworkServices with customHost from configuration
		// This ensures all endpoints use the configured host (sandbox, staging, production, etc.)
		let networkService = NetworkServices(customHost: config.customHost)

        let network = Network(
            service: networkService,
            bearer: nil,
            customHost: config.customHost
        )

		let viewModel = UsersViewModel(
            network: network,
            logger: Logger(category: "StalingBankAssessment"),
            analytics: Analytics()
		)

        return viewModel
	}
}

#if DEBUG
extension ViewModelFactory {
    // When doing UI tests, we need to mock the ViewModel to load local data otherwise
    fileprivate static func loadMockViewModel() -> UsersViewModel? {
        if ProcessInfo.processInfo.arguments.contains("mock"),
           let environment = ProcessInfo.processInfo.environment["mapper"],
           let data = environment.asBase64data,
           let mapper: [NetworkMockData] = data.asObject() {

            let networkService = NetworkServicesMock(mapper: mapper)

            // Mock still needs a customHost for the endpoint URLs to be generated
            let network = Network(
                service: networkService,
                bearer: nil,
                customHost: CustomHost(host: "mock.local", path: "")
            )

            return UsersViewModel(
                network: network,
                logger: Logger(category: "Mock"),
                analytics: Analytics()
            )
        } else {
            return nil
        }
    }
}
#endif
