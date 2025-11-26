import Foundation

extension Array where Element == NetworkMockData {
    /// Converts an array of NetworkMockData to a JSON string for passing through environment variables
    /// Used by UI tests to inject mock data configuration into the app
    public var asString: String {
        return self.asData?.base64EncodedString() ?? ""
    }
}
