import Combine
import Foundation
import LoggerLibrary

// MARK: - Follow Service Protocol -

protocol FollowServiceProtocol {
    var followedUsersPublisher: AnyPublisher<Set<Int>, Never> { get }

    func isFollowing(userId: Int) -> Bool
    func follow(userId: Int)
    func unfollow(userId: Int)
    func toggleFollow(userId: Int)
}

// MARK: - Follow Service -

final class FollowService: FollowServiceProtocol {
    // MARK: - Properties -

    private let storage: StorageProtocol
    private let logger: LoggerProtocol?
    private let followedUsersSubject: CurrentValueSubject<Set<Int>, Never>

    // Cache followed users in memory to avoid reading from storage on every access
    private var cachedFollowedUsers: Set<Int> {
        didSet {
            saveToStorage()
            followedUsersSubject.send(cachedFollowedUsers)
        }
    }

    var followedUsersPublisher: AnyPublisher<Set<Int>, Never> {
        followedUsersSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization -

    init(storage: StorageProtocol,
         logger: LoggerProtocol? = nil) {
        self.storage = storage
        self.logger = logger

        // Load initial state from storage
        let initialUsers = (try? storage.load(forKey: StorageKey.followedUsers, as: Set<Int>.self)) ?? []
        self.cachedFollowedUsers = initialUsers
        self.followedUsersSubject = CurrentValueSubject(initialUsers)

        logger?.debug("Initialized with \(initialUsers.count) followed user(s)")
    }

    // MARK: - Methods -

    func isFollowing(userId: Int) -> Bool {
        return cachedFollowedUsers.contains(userId)
    }

    func follow(userId: Int) {
        cachedFollowedUsers.insert(userId)
    }

    func unfollow(userId: Int) {
        cachedFollowedUsers.remove(userId)
    }

    func toggleFollow(userId: Int) {
        if isFollowing(userId: userId) {
            unfollow(userId: userId)
        } else {
            follow(userId: userId)
        }
    }
}
    // MARK: - Private Methods -

private extension FollowService {
    func saveToStorage() {
        do {
            try storage.save(cachedFollowedUsers, forKey: StorageKey.followedUsers)
            logger?.debug("Saved \(cachedFollowedUsers.count) followed user(s) to storage")
        } catch {
            logger?.error("Failed to save followed users to storage: \(error)")
        }
    }
}
