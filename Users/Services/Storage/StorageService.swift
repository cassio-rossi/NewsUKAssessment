import Foundation

// MARK: - Storage Protocol -

protocol StorageProtocol {
    func save<T: Encodable>(_ value: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String, as type: T.Type) throws -> T?
    func remove(forKey key: String)
    func exists(forKey key: String) -> Bool
}

// MARK: - Storage Service -

final class StorageService: StorageProtocol {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization -

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Convenience -

    /// Convenience accessor for production code
    /// Prefer dependency injection in new code
    static var `default`: StorageService {
        return StorageService()
    }

    // MARK: - Methods -

    func save<T: Encodable>(_ value: T, forKey key: String) throws {
        let data = try encoder.encode(value)
        userDefaults.set(data, forKey: key)
    }

    func load<T: Decodable>(forKey key: String, as type: T.Type) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        return try decoder.decode(type, from: data)
    }

    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
}

// MARK: - Storage Keys -

enum StorageKey {
    static let followedUsers = "followedUsers"
}
