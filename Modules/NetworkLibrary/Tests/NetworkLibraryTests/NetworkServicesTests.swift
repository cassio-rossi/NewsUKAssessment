import Foundation
@testable import NetworkLibrary
import Testing

@Suite("NetworkServices Tests")
struct NetworkServicesTests {

    @Test("Network returns valid response")
    @MainActor
    func validResponse() async throws {
        let host = try #require(URL(string: "example/test"), "Should create valid URL")
        let mapper = [
            NetworkMockData(api: "example/test", filename: "example", bundlePath: Bundle.module.bundlePath)
        ]
        let data = try await NetworkServicesMock(
            customHost: CustomHost(host: "example.com"),
            mapper: mapper
        ).get(url: host, headers: nil)
        #expect(!data.isEmpty)
    }

    @Test("Network handles invalid file")
    @MainActor
    func invalidFile() async throws {
        let host = try #require(URL(string: "invalid"), "Should create valid URL")

        await #expect(throws: NetworkServicesError.network) {
            try await NetworkServicesMock(customHost: CustomHost(host: "example.com")).get(url: host, headers: nil)
        }
    }

    @Test("Network handles failure")
    @MainActor
    func networkFailure() async throws {
        let host = try #require(URL(string: "invalid"), "Should create valid URL")

        await #expect(throws: NetworkServicesError.network) {
            try await NetworkServicesFailed(customHost: CustomHost(host: "example.com")).get(url: host, headers: nil)
        }
    }
}
