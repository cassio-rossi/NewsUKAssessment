import Foundation

// MARK: - ERRORS -

enum ServiceError: Error {
    case network
    case parsing
    case missingBody
    case error(reason: NetworkError)

    var description: String {
        switch self {
        case .network: L10n.NetworkError.network
        case .parsing: L10n.NetworkError.parsing
        case .missingBody: L10n.NetworkError.missingBody
        case .error(let reason): reason.errorDescription
        }
    }
}

struct NetworkError: Decodable {
	let error: String
	let errorDescription: String
}

struct ErrorMessage: Decodable {
	let message: String
}

struct ErrorResponse: Decodable {
	let errors: [ErrorMessage]
	let success: Bool
}
