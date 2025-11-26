import Foundation
import Testing
import UIKit
@testable import Users

// MARK: - Mock Data Provider -

actor MockImageDataProvider: ImageDataProvider {
    var mockData: Data?
    var shouldThrowError = false
    var callCount = 0

    func data(from url: URL) async throws -> (Data, URLResponse) {
        callCount += 1

        if shouldThrowError {
            throw URLError(.badServerResponse)
        }

        guard let data = mockData else {
            throw URLError(.badURL)
        }

        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )! // swiftlint:disable:this force_unwrapping

        return (data, response)
    }

    func reset() {
        mockData = nil
        shouldThrowError = false
        callCount = 0
    }

    func setMockData(_ data: Data) {
        mockData = data
    }

    func setShouldThrowError(_ value: Bool) {
        shouldThrowError = value
    }
}

@Suite("ImageLoader")
struct ImageLoaderTests {

    // MARK: - Helper Methods -

    /// Creates a 1x1 red pixel image data
    private func createTestImageData() -> Data {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }

        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        // swiftlint:disable:next force_unwrapping
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        // swiftlint:disable:next force_unwrapping
        return image.pngData()!
    }

    /// Creates a mock URL
    private func createMockURL() -> URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://example.com/test-image.png")!
    }

    // MARK: - Basic Loading Tests -

    @Test
    func testLoadImageSuccessfully() async throws {
        let mockProvider = MockImageDataProvider()
        await mockProvider.reset()
        await mockProvider.setMockData(createTestImageData())

        let loader = ImageLoader.testInstance(dataProvider: mockProvider)
        let testURL = createMockURL()

        let image = try await loader.loadImage(from: testURL)

        #expect(image != nil)
        let callCount = await mockProvider.callCount
        #expect(callCount == 1)
    }

    @Test
    func testLoadImageWithInvalidData() async throws {
        let mockProvider = MockImageDataProvider()
        await mockProvider.reset()
        // Set invalid image data (just random bytes)
        await mockProvider.setMockData(Data([0x00, 0x01, 0x02]))

        let loader = ImageLoader.testInstance(dataProvider: mockProvider)
        let testURL = createMockURL()

        let image = try await loader.loadImage(from: testURL)

        // Should return nil for invalid image data
        #expect(image == nil)
    }

    @Test
    func testLoadImageWithNetworkError() async throws {
        let mockProvider = MockImageDataProvider()
        await mockProvider.reset()
        await mockProvider.setShouldThrowError(true)

        let loader = ImageLoader.testInstance(dataProvider: mockProvider)
        let testURL = createMockURL()

        do {
            _ = try await loader.loadImage(from: testURL)
            Issue.record("Should have thrown an error")
        } catch {
            // Expected to throw
            #expect(Bool(true))
        }
    }

    // MARK: - Cache Tests -

    @Test
    func testImageIsCachedAfterFirstLoad() async throws {
        let mockProvider = MockImageDataProvider()
        await mockProvider.reset()
        await mockProvider.setMockData(createTestImageData())

        let loader = ImageLoader.testInstance(dataProvider: mockProvider)
        let testURL = createMockURL()

        // First load - should hit the network
        let image1 = try await loader.loadImage(from: testURL)
        #expect(image1 != nil)

        var callCount = await mockProvider.callCount
        #expect(callCount == 1)

        // Second load - should hit the cache
        let image2 = try await loader.loadImage(from: testURL)
        #expect(image2 != nil)

        callCount = await mockProvider.callCount
        #expect(callCount == 1) // Should still be 1, not 2
    }

    @Test
    func testClearCacheRemovesAllImages() async throws {
        let mockProvider = MockImageDataProvider()
        await mockProvider.reset()
        await mockProvider.setMockData(createTestImageData())

        let loader = ImageLoader.testInstance(dataProvider: mockProvider)
        let testURL = createMockURL()

        // Load image to cache it
        _ = try await loader.loadImage(from: testURL)
        var callCount = await mockProvider.callCount
        #expect(callCount == 1)

        // Clear cache
        await loader.clearCache()

        // Load again - should hit network again
        _ = try await loader.loadImage(from: testURL)
        callCount = await mockProvider.callCount
        #expect(callCount == 2)
    }

    @Test
    func testRemoveSpecificImageFromCache() async throws {
        let mockProvider = MockImageDataProvider()
        await mockProvider.reset()
        await mockProvider.setMockData(createTestImageData())

        let loader = ImageLoader.testInstance(dataProvider: mockProvider)
        let testURL = createMockURL()

        // Load image to cache it
        _ = try await loader.loadImage(from: testURL)
        var callCount = await mockProvider.callCount
        #expect(callCount == 1)

        // Remove specific image from cache
        await loader.removeImage(for: testURL)

        // Load again - should hit network again
        _ = try await loader.loadImage(from: testURL)
        callCount = await mockProvider.callCount
        #expect(callCount == 2)
    }

    // MARK: - Concurrent Loading Tests -

    @Test
    func testConcurrentRequestsForSameURLOnlyFetchOnce() async throws {
        let mockProvider = MockImageDataProvider()
        await mockProvider.reset()
        await mockProvider.setMockData(createTestImageData())

        let loader = ImageLoader.testInstance(dataProvider: mockProvider)
        let testURL = createMockURL()

        // Make multiple concurrent requests for the same URL
        async let image1 = loader.loadImage(from: testURL)
        async let image2 = loader.loadImage(from: testURL)
        async let image3 = loader.loadImage(from: testURL)

        let results = try await [image1, image2, image3]

        // All should succeed
        for result in results {
            #expect(result != nil)
        }

        // But should only hit the network once due to task deduplication
        let callCount = await mockProvider.callCount
        #expect(callCount == 1)
    }

    @Test
    func testConcurrentRequestsForDifferentURLs() async throws {
        let mockProvider = MockImageDataProvider()
        await mockProvider.reset()
        await mockProvider.setMockData(createTestImageData())

        let loader = ImageLoader.testInstance(dataProvider: mockProvider)

        // swiftlint:disable force_unwrapping
        let url1 = URL(string: "https://example.com/image1.png")!
        let url2 = URL(string: "https://example.com/image2.png")!
        let url3 = URL(string: "https://example.com/image3.png")!
        // swiftlint:enable force_unwrapping

        // Make concurrent requests for different URLs
        async let image1 = loader.loadImage(from: url1)
        async let image2 = loader.loadImage(from: url2)
        async let image3 = loader.loadImage(from: url3)

        let results = try await [image1, image2, image3]

        // All should succeed
        for result in results {
            #expect(result != nil)
        }

        // Should hit the network 3 times (once per URL)
        let callCount = await mockProvider.callCount
        #expect(callCount == 3)
    }

    // MARK: - Edge Cases -

    @Test
    func testMultipleClearCacheCallsDoNotCrash() async throws {
        let mockProvider = MockImageDataProvider()
        let loader = ImageLoader.testInstance(dataProvider: mockProvider)

        // Call clear cache multiple times
        await loader.clearCache()
        await loader.clearCache()
        await loader.clearCache()

        #expect(Bool(true))
    }

    @Test
    func testRemoveImageForNonExistentURLDoesNotCrash() async throws {
        let mockProvider = MockImageDataProvider()
        let loader = ImageLoader.testInstance(dataProvider: mockProvider)

        // swiftlint:disable force_unwrapping
        let urls = [
            URL(string: "https://example.com/1.png")!,
            URL(string: "https://example.com/2.png")!,
            URL(string: "https://example.com/3.png")!
        ]
        // swiftlint:enable force_unwrapping

        // Remove images that were never cached
        for url in urls {
            await loader.removeImage(for: url)
        }

        #expect(Bool(true))
    }
}
