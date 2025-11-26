import Foundation
import LoggerLibrary
import NetworkLibrary

struct Network {
	let service: NetworkServicesProtocol
	let authorization: [String: String]?
	let customHost: CustomHost
	private let logger = Logger(category: "Network")

	init(service: NetworkServicesProtocol = NetworkServices(),
		 bearer token: String? = nil,
		 customHost: CustomHost) {
		self.service = service
		self.customHost = customHost
		self.authorization = token.map { ["Authorization": "Bearer \($0)"] }
	}
}

// MARK: - Generic Network Helpers -

extension Network {
	/// Generic GET request with automatic JSON parsing
	func get<T: Decodable>(url: URL) async throws -> [T] {
		do {
            let data = try await service.get(url: url, headers: authorization)
			guard let parsed: Stackoverflow<T> = parse(data) else {
				throw ServiceError.parsing
			}
            if let id = parsed.errorId,
               let errorMessage = parsed.errorMessage {
                throw ServiceError.error(reason: .init(error: "\(id)", errorDescription: errorMessage))
            }
            return parsed.items
		} catch let error as NetworkServicesError {
			throw process(error: error)
        } catch let error as ServiceError {
            throw error
		} catch {
			throw ServiceError.network
		}
	}

	/// Generic PUT request with automatic JSON parsing
	func put<T: Decodable, R>(url: URL, body: Data, transform: (T) -> R) async throws -> R {
		do {
			let data = try await service.put(url: url, headers: authorization, body: body)
			guard let parsed: T = parse(data) else {
				throw ServiceError.parsing
			}
			return transform(parsed)
		} catch let error as NetworkServicesError {
			throw process(error: error)
		} catch {
			throw ServiceError.network
		}
	}

	/// Parse JSON data into a Decodable type
	func parse<T: Decodable>(_ data: Data) -> T? {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		do {
			return try decoder.decode(T.self, from: data)
		} catch {
			logger.error("JSON parsing failed for \(T.self): \(error.localizedDescription)")
			return nil
		}
	}
}

// MARK: - Private Error Processing -

private extension Network {
	/// Process NetworkServicesError for async/await methods
	func process(error: NetworkServicesError) -> ServiceError {
		switch error {
		case .network: .network
		case .noData: .parsing
		case .error(let reason): process(data: reason)
		}
	}

	func process(data: Data?) -> ServiceError {
		var returnValue = ServiceError.parsing

		// Failed could happen at authorization or request level
		// Response object are different
		if let authParsed: NetworkError = parse(data ?? Data()) {
			returnValue = .error(reason: authParsed)
		} else if let requestParsed: ErrorResponse = parse(data ?? Data()) {
			returnValue = .error(reason: NetworkError(error: "",
													  errorDescription: requestParsed.errors.description))
		}

		return returnValue
	}
}
