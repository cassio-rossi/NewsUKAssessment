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
    fileprivate static func loadMockViewModel() -> UsersViewModel? {
        if ProcessInfo.processInfo.arguments.contains("mock") {
            let bundle = {
                guard let bundle = ProcessInfo.processInfo.environment["bundle"] else {
                    return Bundle.main
                }
                return Bundle(path: bundle) ?? Bundle.main
            }()

            let networkService = NetworkServicesMock(bundle: bundle)
            // Mock still needs a customHost for the endpoint URLs to be generated
            let network = Network(
                service: networkService,
                bearer: nil,
                customHost: CustomHost(host: "mock.local", path: "/2.2")
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
