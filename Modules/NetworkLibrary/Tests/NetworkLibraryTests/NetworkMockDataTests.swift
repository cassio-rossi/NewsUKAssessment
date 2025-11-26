import Foundation
@testable import NetworkLibrary
import Testing

@Suite("NetworkMockData Encoding/Decoding Tests")
struct NetworkMockDataTests {

    @Test("Array to base64 string encoding")
    func arrayToBase64String() throws {
        // Given
        let mapper = [
            NetworkMockData(api: "/users", filename: "error", bundlePath: "/test/path")
        ]

        // When
        let base64String = mapper.asString

        // Then
        #expect(!base64String.isEmpty, "Base64 string should not be empty")

        // Verify it's valid base64 by decoding it
        let decodedData = Data(base64Encoded: base64String)
        #expect(decodedData != nil, "Should be valid base64")

        // Verify the decoded data contains valid JSON
        if let data = decodedData {
            let decoded = try? JSONDecoder().decode([NetworkMockData].self, from: data)
            #expect(decoded != nil, "Decoded data should be valid JSON")
        }
    }

    @Test("Base64 string to Data conversion")
    func base64StringToData() throws {
        // Given: Create a base64 encoded JSON
        let jsonData = try JSONEncoder().encode([
            NetworkMockData(api: "/2.2/users", filename: "error", bundlePath: "/test/path")
        ])
        let base64String = jsonData.base64EncodedString()

        // When
        let data = base64String.asBase64data

        // Then
        let result = try #require(data, "Should convert base64 string to data")
        #expect(result.count > 0, "Data should not be empty")

        // Verify it's valid JSON
        let decoded = try? JSONDecoder().decode([NetworkMockData].self, from: result)
        #expect(decoded != nil, "Data should be decodable as JSON")
    }

    @Test("Data to Object decoding")
    func dataToObject() throws {
        // Given
        let jsonString = "[{\"api\":\"/2.2/users\",\"filename\":\"error\",\"bundlePath\":\"/test/path\"}]"
        let data = jsonString.asData

        // When
        let decoded: [NetworkMockData]? = data.asObject()

        // Then
        let result = try #require(decoded, "Should decode successfully")
        #expect(result.count == 1, "Should have 1 element")
        #expect(result[0].api == "/2.2/users", "API should match")
        #expect(result[0].filename == "error", "Filename should match")
        #expect(result[0].bundlePath == "/test/path", "Bundle path should match")
    }

    @Test("Full round-trip: Object → Base64 String → Environment → Data → Object")
    func fullRoundTrip() throws {
        // Given: Original object
        let original = [
            NetworkMockData(api: "/2.2/users", filename: "error", bundlePath: "/test/path")
        ]

        // Step 1: Object → Base64 String (encoding side - UI Test)
        let base64String = original.asString
        #expect(!base64String.isEmpty, "Step 1: Base64 string should not be empty")

        // Step 2: String passes through environment variable (no conversion)
        let environmentString = base64String
        #expect(environmentString == base64String, "Step 2: String should pass through unchanged")

        // Step 3: Base64 String → Data (decoding side - App)
        let data = try #require(environmentString.asBase64data, "Step 3: Should convert to data")
        #expect(data.count > 0, "Step 3: Data should not be empty")

        // Step 4: Data → Object (decoding side - App)
        let decoded: [NetworkMockData]? = data.asObject()
        let result = try #require(decoded, "Step 4: Should decode successfully")

        // Verify: Compare original with decoded
        #expect(result.count == 1, "Should have same number of elements")
        #expect(result[0].api == original[0].api, "API should match")
        #expect(result[0].filename == original[0].filename, "Filename should match")
        #expect(result[0].bundlePath == original[0].bundlePath, "Bundle path should match")
    }

    @Test("Round-trip with nil bundlePath")
    func roundTripWithNilBundlePath() throws {
        // Given
        let original = [
            NetworkMockData(api: "/2.2/users", filename: "error", bundlePath: nil)
        ]

        // When
        let base64String = original.asString
        let data = try #require(base64String.asBase64data, "Should convert to data")
        let decoded: [NetworkMockData]? = data.asObject()

        // Then
        let result = try #require(decoded, "Should decode successfully")
        #expect(result[0].api == original[0].api, "API should match")
        #expect(result[0].filename == original[0].filename, "Filename should match")
        #expect(result[0].bundlePath == nil, "Bundle path should be nil")
    }

    @Test("Round-trip with multiple elements")
    func roundTripMultipleElements() throws {
        // Given
        let original = [
            NetworkMockData(api: "/2.2/users", filename: "error", bundlePath: "/test/path1"),
            NetworkMockData(api: "/2.2/posts", filename: "posts", bundlePath: "/test/path2"),
            NetworkMockData(api: "/2.2/comments", filename: "comments", bundlePath: nil)
        ]

        // When
        let base64String = original.asString
        let data = try #require(base64String.asBase64data, "Should convert to data")
        let decoded: [NetworkMockData]? = data.asObject()

        // Then
        let result = try #require(decoded, "Should decode successfully")
        #expect(result.count == 3, "Should have 3 elements")

        for i in 0..<3 {
            #expect(result[i].api == original[i].api, "API[\(i)] should match")
            #expect(result[i].filename == original[i].filename, "Filename[\(i)] should match")
            #expect(result[i].bundlePath == original[i].bundlePath, "Bundle path[\(i)] should match")
        }
    }

    @Test("Round-trip with special characters in paths")
    func roundTripSpecialCharacters() throws {
        // Given
        let original = [
            NetworkMockData(
                api: "/api/v1/users",
                filename: "test-file_name",
                bundlePath: "/Users/test user/Library/Developer/Xcode/path with spaces"
            )
        ]

        // When
        let base64String = original.asString
        let data = try #require(base64String.asBase64data, "Should convert to data")
        let decoded: [NetworkMockData]? = data.asObject()

        // Then
        let result = try #require(decoded, "Should decode successfully")
        #expect(result[0].api == original[0].api, "API should match")
        #expect(result[0].filename == original[0].filename, "Filename should match")
        #expect(result[0].bundlePath == original[0].bundlePath, "Bundle path with spaces should match")
    }

    @Test("Decoding empty array")
    func emptyArray() throws {
        // Given
        let original: [NetworkMockData] = []

        // When
        let base64String = original.asString
        let data = try #require(base64String.asBase64data, "Should convert to data")
        let decoded: [NetworkMockData]? = data.asObject()

        // Then
        let result = try #require(decoded, "Should decode empty array successfully")
        #expect(result.isEmpty, "Result should be empty")
    }

    @Test("Decoding invalid base64 returns nil")
    func invalidBase64() throws {
        // Given
        let invalidBase64 = "not valid base64!!!"

        // When
        let data = invalidBase64.asBase64data

        // Then
        #expect(data == nil, "Invalid base64 should return nil")
    }

    @Test("Decoding invalid JSON returns nil")
    func invalidJSON() throws {
        // Given: Valid base64 but invalid JSON
        let invalidJSON = "not valid json"
        let base64String = Data(invalidJSON.utf8).base64EncodedString()

        // When
        let data = try #require(base64String.asBase64data, "Should decode base64")
        let decoded: [NetworkMockData]? = data.asObject()

        // Then
        #expect(decoded == nil, "Invalid JSON should return nil")
    }
}
