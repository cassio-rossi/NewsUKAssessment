import Foundation
import NetworkLibrary

/// Endpoints related to users operations
enum UsersEndpoint {
    case users

    /// Generate endpoint with the provided customHost
    /// - Parameter customHost: The API host from configuration
    /// - Returns: Configured Endpoint
    func endpoint(with customHost: CustomHost) -> Endpoint {
        switch self {
        case .users:
            let queryItems = [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "pagesize", value: "20"),
                URLQueryItem(name: "order", value: "desc"),
                URLQueryItem(name: "sort", value: "reputation"),
                URLQueryItem(name: "site", value: "stackoverflow")
            ]
            return Endpoint(
                customHost: customHost,
                api: "/users",
                queryItems: queryItems
            )
        }
    }
}
