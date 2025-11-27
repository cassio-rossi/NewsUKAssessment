import Foundation

extension HTTPURLResponse {
	var hasSuccessStatusCode: Bool { 200...299 ~= statusCode }
	var hasErrorStatusCode: Bool { 400...499 ~= statusCode }
}

// MARK: - NetworkServices Custom Implementation -

public final class NetworkServices: NSObject, NetworkServicesProtocol {

	/// Custom host allows to replace the default host used by the library
	/// allowing the usage of different environments like `debug`, `qa` or `production`
	public var customHost: CustomHost

	/// Certificates to be used while URLAuthenticationChallenge as SSL Pinning
	public private(set) var certificates: [SecCertificate]?

	/// Initialization method
	///
	/// - Parameter customHost: A custom host object to allow override of host, path and api
	public init(customHost: CustomHost,
				certificates: [SecCertificate]? = nil) {
		self.customHost = customHost
		self.certificates = certificates
	}

	/// HTTP GET Method
	///
	/// - Parameter url: The URL to make the request
	/// - Parameter headers: Optional headers to perform the request
	/// - Returns: Data from the response
	/// - Throws: NetworkServicesError if the request fails
	public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
		let request = createRequest(method: "GET", url: url, headers: headers)
		return try await execute(request: request)
	}

	/// HTTP PUT Method
	///
	/// - Parameter url: The URL to make the request
	/// - Parameter headers: Optional headers to perform the request
	/// - Parameter body: The body, usually a JSON data to be sent on the request
	/// - Returns: Data from the response
	/// - Throws: NetworkServicesError if the request fails
	public func put(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
		let request = createRequest(method: "PUT", url: url, headers: headers, body: body)
		return try await execute(request: request)
	}
}

extension NetworkServices {
	// Create a URLRequest request to be used on the URLSession
	fileprivate func createRequest(method: String, url: URL, headers: [String: String]? = nil, body: Data? = nil) -> URLRequest {
		var request = URLRequest(url: url)
		request.httpMethod = method

		if method == "POST" || method == "PUT" {
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		}
		headers?.forEach { key, value in
			request.setValue(value, forHTTPHeaderField: key)
		}

		if let body {
			request.httpBody = body
		}

		return request
	}

	// Executing the network request
	fileprivate func execute(request: URLRequest) async throws -> Data {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.timeoutIntervalForRequest = 30

        let session = URLSession(configuration: configuration,
								 delegate: NetworkServicesDelegate(certificates: certificates),
								 delegateQueue: nil)

		do {
			let (data, response) = try await session.data(for: request)

			guard let httpResponse = response as? HTTPURLResponse else {
				throw NetworkServicesError.network
			}

			if httpResponse.hasSuccessStatusCode {
				return data
			} else if httpResponse.hasErrorStatusCode {
				throw NetworkServicesError.error(reason: data)
			} else {
				throw NetworkServicesError.network
			}
		} catch let error as NetworkServicesError {
			throw error
		} catch {
			throw NetworkServicesError.error(reason: error.localizedDescription.data(using: .utf8))
		}
	}
}
