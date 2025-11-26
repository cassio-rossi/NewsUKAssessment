import Foundation
@testable import NetworkLibrary
import Testing

@Suite("NetworkServices Tests")
struct NetworkServicesTests {

    @Test("Network returns valid response")
    @MainActor
    func validResponse() async throws {
        let host = try #require(URL(string: "example/test"), "Should create valid URL")

        let data = try await NetworkServicesMock(
            bundle: Bundle.module,
            mapper: ["example/test": "example"]
        ).get(url: host, headers: nil)
        #expect(!data.isEmpty)
    }

    @Test("Network handles invalid file")
    @MainActor
    func invalidFile() async throws {
        let host = try #require(URL(string: "invalid"), "Should create valid URL")

        await #expect(throws: NetworkServicesError.network) {
            try await NetworkServicesMock(bundle: Bundle.module).get(url: host, headers: nil)
        }
    }

    @Test("Network handles failure")
    @MainActor
    func networkFailure() async throws {
        let host = try #require(URL(string: "invalid"), "Should create valid URL")

        await #expect(throws: NetworkServicesError.network) {
            try await NetworkServicesFailed().get(url: host, headers: nil)
        }
    }
}
