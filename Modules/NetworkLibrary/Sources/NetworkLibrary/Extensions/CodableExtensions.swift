import Foundation

extension Encodable {
	/// Convert a Codable object into a Data object to be sent on a network request
	public var asData: Data? {
		try? JSONEncoder().encode(self)
	}
}
