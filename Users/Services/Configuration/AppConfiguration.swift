import Foundation
import NetworkLibrary

/// Protocol defining the configuration requirements for the application
/// This allows dependency injection and makes the code testable and reusable
protocol AppConfiguration {
	/// The API host configuration (host and base path)
	/// This is required since endpoints need to know where to send requests
	var customHost: CustomHost { get }
}
