import Foundation

extension Int {
    var formated: String {
        switch self {
        case 1_000_000...:
            return String(format: "%.1fM", Double(self) / 1_000_000)
        case 10_000...:
            return String(format: "%.0fk", Double(self) / 1_000)
        case 1_000...:
            return String(format: "%.1fk", Double(self) / 1_000)
        default:
            return "\(self)"
        }
    }
}
