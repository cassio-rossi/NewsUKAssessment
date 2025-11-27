import Foundation

// MARK: - Network Errors -

public enum NetworkServicesError: Error, Equatable {
	case network
	case noData
	case error(reason: Data?)
}

extension NetworkServicesError: CustomStringConvertible {
	public var description: String {
		switch self {
		case .network:
			return "An error occurred while fetching data".localized
		case .noData:
			return "No data received from the request".localized
		case .error(let reason):
			guard let reason,
				  let data = String(data: reason, encoding: .utf8) else {
				return "An error occurred while fetching data".localized
			}
			let title = "An error occurred while fetching with data: %@".localized
			return String.localizedStringWithFormat(title, data)
		}
	}
}

// MARK: - NetworkServices Protocol -

/// Protocol to create the network layer
public protocol NetworkServicesProtocol {
	/// Custom host allows to replace the default host used by the library
	/// allowing the usage of different environments like `debug`, `qa` or `production`
	var customHost: CustomHost { get }

	/// Certificates to be used while URLAuthenticationChallenge as SSL Pinning
	var certificates: [SecCertificate]? { get }

	/// HTTP GET Method
	///
	/// - Parameter url: The URL to make the request
	/// - Parameter headers: Optional headers to perform the request
	/// - Returns: Data from the response
	/// - Throws: NetworkServicesError if the request fails
	func get(url: URL, headers: [String: String]?) async throws -> Data

	/// HTTP PUT Method
	///
	/// - Parameter url: The URL to make the request
	/// - Parameter headers: Optional headers to perform the request
	/// - Parameter body: The body, usually a JSON data to be sent on the request
	/// - Returns: Data from the response
	/// - Throws: NetworkServicesError if the request fails
	func put(url: URL, headers: [String: String]?, body: Data) async throws -> Data
}
