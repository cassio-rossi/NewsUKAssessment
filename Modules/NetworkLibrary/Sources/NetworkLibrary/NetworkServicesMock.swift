#if DEBUG
import Foundation

// MARK: - NetworkServices Mock Implementation -

public final class NetworkServicesMock: NSObject, NetworkServicesProtocol {

    private var mapper = [NetworkMockData]()

	/// Custom host allows to replace the default host used by the library
	/// allowing the usage of different environments like `debug`, `qa` or `production`
	public var customHost: CustomHost?

	/// Certificates to be used while URLAuthenticationChallenge as SSL Pinning
	public private(set) var certificates: [SecCertificate]?

	/// Initialization method
	public override init() {}

    /// Initialization method
    ///
    /// - Parameter customHost: A custom host object to allow override of host, path and api
    /// - Parameter certificates: An array of certificates to help SSL pinning
    /// - Parameter mapper: A NetworkMockData object mapping api against local file for mocking purposes
    public convenience init(customHost: CustomHost? = nil,
                            certificates: [SecCertificate]? = nil,
                            mapper: [NetworkMockData] = []) {
        self.init()
        self.customHost = customHost
        self.certificates = certificates
        self.mapper = mapper
    }

    /// HTTP GET Method
	public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
        try await loadFile(from: url)
	}

	/// HTTP PUT Method
	public func put(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
		try await loadFile(from: url)
	}
}

private extension NetworkServicesMock {
    func loadFile(from url: URL) async throws -> Data {
        // Determine which mock file to load based on the URL path
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let mockObject = mapper.first(where: { $0.api == components.path }) else {
            throw NetworkServicesError.network
        }
        let bundle = {
            if let bundlePath = mockObject.bundlePath {
                Bundle(path: bundlePath)
            } else {
                Bundle.main
            }
        }()
            guard let path = bundle?.path(forResource: mockObject.filename, ofType: "json"),
              let content = FileManager.default.contents(atPath: path) else {
            throw NetworkServicesError.network
        }
        return content
    }
}

public final class NetworkServicesFailed: NSObject, NetworkServicesProtocol {
	/// Custom host allows to replace the default host used by the library
	/// allowing the usage of different environments like `debug`, `qa` or `production`
	public var customHost: CustomHost?

	/// Certificates to be used while URLAuthenticationChallenge as SSL Pinning
	public private(set) var certificates: [SecCertificate]?

	/// HTTP GET Method - Always fails
	public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
		throw NetworkServicesError.network
	}

	/// HTTP PUT Method - Always fails
	public func put(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
		throw NetworkServicesError.network
	}

	/// Load a mocked file - Always fails
	public func load(file: String) async throws -> Data {
		throw NetworkServicesError.network
	}
}
#endif
