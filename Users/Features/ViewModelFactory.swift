import AnalyticsLibrary
import Foundation
import LoggerLibrary
import NetworkLibrary

struct ViewModelFactory {
	/// Dependency container managing service instances
	static var dependencies: DependencyContainer = .default

	static var usersViewModel: UsersViewModel {
        UsersViewModel(
            network: Network(
                service: dependencies.networkServices,
                logger: dependencies.logger
            ),
            logger: dependencies.logger,
            analytics: dependencies.analytics,
            followService: dependencies.followService
        )
	}
}
