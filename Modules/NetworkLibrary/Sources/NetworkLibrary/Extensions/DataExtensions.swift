import Foundation

extension Data {
    /// The data converted to a UTF-8 string.
    public var asString: String? {
        return String(data: self, encoding: .utf8)
    }

    /// Restore the initial struct based on a String
    public func asObject<T: Decodable>() -> T? {
        try? JSONDecoder().decode(T.self, from: self)
    }
}
