import Foundation

extension Bundle {
    /// The bundle identifier of the main bundle.
    static var mainBundleIdentifier: String {
        guard let identifier = self.main.bundleIdentifier else {
            return ""
        }
        return identifier
    }
}
