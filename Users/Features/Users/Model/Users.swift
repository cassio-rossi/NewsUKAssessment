import Foundation

// MARK: - USERS -

struct User: Decodable {
    let badgeCounts: BadgeCounts
    let userId: Int
    let displayName: String
    let profileImage: URL?
    let link: URL
    let location: String?
    let reputation: Int
}

struct BadgeCounts: Decodable {
    let bronze: Int
    let silver: Int
    let gold: Int
}
