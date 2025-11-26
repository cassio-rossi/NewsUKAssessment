# NetworkServices

A lightweight, protocol-oriented Swift networking layer with built-in SSL pinning support, designed for iOS 15+. This module provides a clean abstraction over URLSession with comprehensive error handling, environment flexibility, and testing utilities.

## Features

- **Swift Concurrency First** - Modern async/await API with structured concurrency support
- **Protocol-Oriented Design** - Easily mockable and testable with `NetworkServicesProtocol`
- **SSL Certificate Pinning** - Built-in support for enhanced security
- **Environment Management** - Flexible host configuration for development, staging, and production
- **Comprehensive Error Handling** - Type-safe error cases with localized descriptions
- **RESTful API Support** - Clean interfaces for GET and PUT requests
- **Built-in Mocking** - Debug-only mock implementations for local testing
- **Zero Dependencies** - Pure Swift with no external frameworks

## Requirements

- iOS 17.0+
- Swift 6.2+
- Xcode 26.0+

## Usage

### Basic Setup

```swift
import NetworkLibrary

// Initialize with default configuration
let networkService = NetworkServices()

// Or with SSL pinning
let certificates = [/* your SecCertificate objects */]
let secureService = NetworkServices(certificates: certificates)
```

### Environment Configuration

Configure different environments using `CustomHost`:

```swift
let customHost = CustomHost(
    secure: true,
    host: "api.example.com",
    path: "/v1",
    api: "users"
)

let networkService = NetworkServices(customHost: customHost)
```

### Making Requests (Async/Await)

#### GET Request

```swift
let endpoint = Endpoint(
    customHost: customHost,
    api: "/users",
    queryItems: [URLQueryItem(name: "limit", value: "10")]
)

Task {
    do {
        let data = try await networkService.get(url: endpoint.url, headers: nil)
        // Decode your model from data
        let users = try JSONDecoder().decode([User].self, from: data)
        print("Fetched \(users.count) users")
    } catch let error as NetworkServicesError {
        print("Network error: \(error.description)")
    } catch {
        print("Decoding error: \(error)")
    }
}
```

#### PUT Request

```swift
let updatedUser = User(name: "Jane Doe", email: "jane@example.com")
let body = try JSONEncoder().encode(updatedUser)

Task {
    do {
        let data = try await networkService.put(url: endpoint.url, headers: nil, body: body)
        let response = try JSONDecoder().decode(UpdateResponse.self, from: data)
        print("Update successful: \(response)")
    } catch {
        print("Update failed: \(error)")
    }
}
```

### Custom Headers

```swift
let headers = [
    "Authorization": "Bearer \(token)",
    "X-Custom-Header": "value"
]

Task {
    do {
        let data = try await networkService.get(url: endpoint.url, headers: headers)
        // Handle response
    } catch {
        // Handle error
    }
}
```

### Using with @MainActor ViewModels

```swift
@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var error: NetworkServicesError?

    private let networkService: NetworkServicesProtocol

    init(networkService: NetworkServicesProtocol = NetworkServices()) {
        self.networkService = networkService
    }

    func fetchUsers() async {
        do {
            let data = try await networkService.get(url: endpoint.url, headers: nil)
            self.users = try JSONDecoder().decode([User].self, from: data)
            self.error = nil
        } catch let error as NetworkServicesError {
            self.error = error
        }
    }
}
```

## Testing

### Using Mocks in Debug Builds

The module includes `NetworkServicesMock` for testing with local JSON files:

```swift
#if DEBUG
let mockService = NetworkServicesMock(
    bundle: Bundle.main,
    customHost: customHost
)

Task {
    do {
        // Returns data from users.json in your bundle
        let data = try await mockService.get(url: URL(string: "users")!, headers: nil)
        let users = try JSONDecoder().decode([User].self, from: data)
        print("Loaded \(users.count) mock users")
    } catch {
        print("Mock loading failed: \(error)")
    }
}
#endif
```

### Loading Mock Files

The mock service can also load arbitrary JSON files:

```swift
#if DEBUG
Task {
    do {
        let data = try await mockService.load(file: "test-data")
        // Process test-data.json
    } catch {
        print("Failed to load mock: \(error)")
    }
}
#endif
```

### Protocol-Based Testing

Inject the protocol for easy testing:

```swift
class UserRepository {
    let networkService: NetworkServicesProtocol

    init(networkService: NetworkServicesProtocol) {
        self.networkService = networkService
    }

    func fetchUsers() async throws -> [User] {
        let data = try await networkService.get(url: endpoint.url, headers: nil)
        return try JSONDecoder().decode([User].self, from: data)
    }
}

// In production
let repo = UserRepository(networkService: NetworkServices())

// In tests
let repo = UserRepository(networkService: NetworkServicesMock(bundle: Bundle(for: MyTests.self)))
```

### Swift Testing Example

```swift
import Testing
import NetworkLibrary

@Suite("User Repository Tests")
struct UserRepositoryTests {
    private let mockService = NetworkServicesMock(bundle: Bundle.module)

    @Test("Fetch users success")
    func testFetchUsersSuccess() async throws {
        let repo = UserRepository(networkService: mockService)
        let users = try await repo.fetchUsers()

        #expect(users.count > 0)
    }

    @Test("Fetch users failure")
    func testFetchUsersFailure() async {
        let failedService = NetworkServicesFailed()
        let repo = UserRepository(networkService: failedService)

        do {
            _ = try await repo.fetchUsers()
            Issue.record("Should have thrown an error")
        } catch {
            #expect(error is NetworkServicesError)
        }
    }
}
```

## Architecture

### Core Components

- **`NetworkServices`** - Main implementation of the networking layer
- **`NetworkServicesProtocol`** - Protocol defining the networking interface
- **`Endpoint`** - URL builder with support for custom hosts and query parameters
- **`CustomHost`** - Configuration object for environment-specific settings
- **`NetworkServicesError`** - Type-safe error handling with localized messages
- **`NetworkServicesDelegate`** - URLSession delegate handling SSL pinning

### Error Handling

Three distinct error cases for clarity:

```swift
public enum NetworkServicesError: Error {
    case network        // General network error
    case noData         // No data received from server
    case error(reason: Data?)  // Server returned error with optional data
}
```

All errors conform to `CustomStringConvertible` with localized messages.

### API Methods

```swift
// GET request
func get(url: URL, headers: [String: String]?) async throws -> Data

// PUT request
func put(url: URL, headers: [String: String]?, body: Data) async throws -> Data

// Load mock file
func load(file: String) async throws -> Data
```

## Security

### SSL Certificate Pinning

Enhance security by pinning SSL certificates:

```swift
// Load your certificate
guard let certPath = Bundle.main.path(forResource: "certificate", ofType: "cer"),
      let certData = try? Data(contentsOf: URL(fileURLWithPath: certPath)),
      let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
    fatalError("Could not load certificate")
}

let networkService = NetworkServices(certificates: [certificate])
```

The delegate automatically validates certificates against pinned certificates and handles common SSL errors gracefully.
