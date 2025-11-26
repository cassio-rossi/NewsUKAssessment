import Foundation

struct Stackoverflow<T: Decodable>: Decodable {
    let items: [T]
    let hasMore: Bool
    let quotaMax: Int
    let quotaRemaining: Int
    let errorId: Int?
    let errorMessage: String?
}
