import UIKit

// MARK: - Protocol for Dependency Injection -

protocol ImageDataProvider {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: ImageDataProvider {}

// MARK: - ImageLoader -

actor ImageLoader {
    static let shared = ImageLoader()

    // MARK: - Properties -

    private let cache = NSCache<NSURL, UIImage>()
    private var runningTasks = [URL: Task<UIImage?, Error>]()
    private let dataProvider: ImageDataProvider

    // MARK: - Initialization -

    private init(dataProvider: ImageDataProvider = URLSession.shared) {
        self.dataProvider = dataProvider
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    /// Creates a testable instance with a custom data provider
    /// - Parameter dataProvider: Custom data provider for testing
    /// - Returns: New ImageLoader instance
    static func testInstance(dataProvider: ImageDataProvider) -> ImageLoader {
        return ImageLoader(dataProvider: dataProvider)
    }

    // MARK: - Methods -

    func loadImage(from url: URL) async throws -> UIImage? {
        // Check memory cache first
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        // Check if there's already a running task for this URL
        if let existingTask = runningTasks[url] {
            return try await existingTask.value
        }

        // Create new task
        let task = Task<UIImage?, Error> {
            let (data, _) = try await dataProvider.data(from: url)
            guard let image = UIImage(data: data) else {
                return nil
            }

            // Cache the image
            self.cache.setObject(image, forKey: url as NSURL)
            return image
        }

        runningTasks[url] = task

        defer {
            runningTasks.removeValue(forKey: url)
        }

        return try await task.value
    }

    func clearCache() {
        cache.removeAllObjects()
        runningTasks.removeAll()
    }

    func removeImage(for url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }
}
