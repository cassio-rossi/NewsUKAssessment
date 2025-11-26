import Foundation
import LoggerLibrary
import Testing
@testable import Users

// MARK: - Mock Storage -

final class MockStorage: StorageProtocol {
    private var storage: [String: Data] = [:]

    func save<T: Encodable>(_ value: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        storage[key] = try encoder.encode(value)
    }

    func load<T: Decodable>(forKey key: String, as type: T.Type) throws -> T? {
        guard let data = storage[key] else { return nil }
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }

    func remove(forKey key: String) {
        storage.removeValue(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        return storage[key] != nil
    }

    func clear() {
        storage.removeAll()
    }
}

// MARK: - FollowService Tests -

@Suite("FollowService")
struct FollowServiceTests {

    // MARK: - Basic Follow/Unfollow Tests -

    @Test
    @MainActor
    func testFollowUser() throws {
        let mockStorage = MockStorage()
        let service = FollowService(
            storage: mockStorage,
            logger: Logger(category: "Test")
        )

        let userId = 123

        #expect(!service.isFollowing(userId: userId))

        service.follow(userId: userId)

        #expect(service.isFollowing(userId: userId))
    }

    @Test
    @MainActor
    func testUnfollowUser() throws {
        let mockStorage = MockStorage()
        let service = FollowService(storage: mockStorage)

        let userId = 456

        // Follow first
        service.follow(userId: userId)
        #expect(service.isFollowing(userId: userId))

        // Then unfollow
        service.unfollow(userId: userId)
        #expect(!service.isFollowing(userId: userId))
    }

    @Test
    @MainActor
    func testToggleFollow() throws {
        let mockStorage = MockStorage()
        let service = FollowService(storage: mockStorage)

        let userId = 789

        // Initially not following
        #expect(!service.isFollowing(userId: userId))

        // Toggle to follow
        service.toggleFollow(userId: userId)
        #expect(service.isFollowing(userId: userId))

        // Toggle to unfollow
        service.toggleFollow(userId: userId)
        #expect(!service.isFollowing(userId: userId))
    }

    // MARK: - Multiple Users Tests -

    @Test
    @MainActor
    func testFollowMultipleUsers() throws {
        let mockStorage = MockStorage()
        let service = FollowService(storage: mockStorage)

        let userIds = [1, 2, 3, 4, 5]

        for userId in userIds {
            service.follow(userId: userId)
        }

        for userId in userIds {
            #expect(service.isFollowing(userId: userId))
        }
    }

    @Test
    @MainActor
    func testUnfollowOneOfMultipleUsers() throws {
        let mockStorage = MockStorage()
        let service = FollowService(storage: mockStorage)

        let userIds = [10, 20, 30]

        // Follow all
        for userId in userIds {
            service.follow(userId: userId)
        }

        // Unfollow one
        service.unfollow(userId: 20)

        #expect(service.isFollowing(userId: 10))
        #expect(!service.isFollowing(userId: 20))
        #expect(service.isFollowing(userId: 30))
    }

    // MARK: - Persistence Tests -

    @Test
    @MainActor
    func testFollowedUsersArePersisted() throws {
        let mockStorage = MockStorage()

        // Create first service instance and follow users
        let service1 = FollowService(storage: mockStorage)
        service1.follow(userId: 100)
        service1.follow(userId: 200)

        // Create second service instance with same storage
        let service2 = FollowService(storage: mockStorage)

        // Should load previously followed users
        #expect(service2.isFollowing(userId: 100))
        #expect(service2.isFollowing(userId: 200))
    }

    @Test
    @MainActor
    func testUnfollowPersists() throws {
        let mockStorage = MockStorage()

        let service1 = FollowService(storage: mockStorage)
        service1.follow(userId: 300)
        service1.follow(userId: 400)

        // Unfollow one
        service1.unfollow(userId: 300)

        // Create new instance
        let service2 = FollowService(storage: mockStorage)

        #expect(!service2.isFollowing(userId: 300))
        #expect(service2.isFollowing(userId: 400))
    }

    // MARK: - Edge Cases -

    @Test
    @MainActor
    func testFollowingSameUserTwice() throws {
        let mockStorage = MockStorage()
        let service = FollowService(storage: mockStorage)

        let userId = 500

        service.follow(userId: userId)
        service.follow(userId: userId)

        #expect(service.isFollowing(userId: userId))
    }

    @Test
    @MainActor
    func testUnfollowingUserNotFollowed() throws {
        let mockStorage = MockStorage()
        let service = FollowService(storage: mockStorage)

        let userId = 600

        // Try to unfollow without following first
        service.unfollow(userId: userId)

        #expect(!service.isFollowing(userId: userId))
    }

    @Test
    @MainActor
    func testIsFollowingWithEmptyStorage() throws {
        let mockStorage = MockStorage()
        let service = FollowService(storage: mockStorage)

        #expect(!service.isFollowing(userId: 999))
    }
}

// MARK: - StorageService Tests -

@Suite("StorageService")
struct StorageServiceTests {

    @Test
    @MainActor
    func testSaveAndLoadString() throws {
        let mockDefaults = UserDefaults(suiteName: "test.storage")
        // swiftlint:disable:next force_unwrapping
        mockDefaults!.removePersistentDomain(forName: "test.storage")

        // swiftlint:disable:next force_unwrapping
        let storage = StorageService(userDefaults: mockDefaults!)

        let testValue = "Hello, World!"
        try storage.save(testValue, forKey: "testString")

        let loaded: String? = try storage.load(forKey: "testString", as: String.self)
        #expect(loaded == testValue)
    }

    @Test
    @MainActor
    func testSaveAndLoadSet() throws {
        let mockDefaults = UserDefaults(suiteName: "test.storage.set")
        // swiftlint:disable:next force_unwrapping
        mockDefaults!.removePersistentDomain(forName: "test.storage.set")

        // swiftlint:disable:next force_unwrapping
        let storage = StorageService(userDefaults: mockDefaults!)

        let testSet: Set<Int> = [1, 2, 3, 4, 5]
        try storage.save(testSet, forKey: "testSet")

        let loaded: Set<Int>? = try storage.load(forKey: "testSet", as: Set<Int>.self)
        #expect(loaded == testSet)
    }

    @Test
    @MainActor
    func testLoadNonExistentKey() throws {
        let mockDefaults = UserDefaults(suiteName: "test.storage.nonexistent")
        // swiftlint:disable:next force_unwrapping
        mockDefaults!.removePersistentDomain(forName: "test.storage.nonexistent")

        // swiftlint:disable:next force_unwrapping
        let storage = StorageService(userDefaults: mockDefaults!)

        let loaded: String? = try storage.load(forKey: "nonexistent", as: String.self)
        #expect(loaded == nil)
    }

    @Test
    @MainActor
    func testRemoveValue() throws {
        let mockDefaults = UserDefaults(suiteName: "test.storage.remove")
        // swiftlint:disable:next force_unwrapping
        mockDefaults!.removePersistentDomain(forName: "test.storage.remove")

        // swiftlint:disable:next force_unwrapping
        let storage = StorageService(userDefaults: mockDefaults!)

        try storage.save("test", forKey: "removeMe")
        #expect(storage.exists(forKey: "removeMe"))

        storage.remove(forKey: "removeMe")
        #expect(!storage.exists(forKey: "removeMe"))
    }

    @Test
    @MainActor
    func testExists() throws {
        let mockDefaults = UserDefaults(suiteName: "test.storage.exists")
        // swiftlint:disable:next force_unwrapping
        mockDefaults!.removePersistentDomain(forName: "test.storage.exists")

        // swiftlint:disable:next force_unwrapping
        let storage = StorageService(userDefaults: mockDefaults!)

        #expect(!storage.exists(forKey: "notThere"))

        try storage.save(42, forKey: "isThere")
        #expect(storage.exists(forKey: "isThere"))
    }
}
