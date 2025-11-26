# Users App

A native iOS application that displays Stack Overflow users in a responsive grid layout with follow functionality and persistent storage.

## Features

- **User Display**: Grid layout showing Stack Overflow users with profile images, names, locations, and reputation
- **Follow System**: Toggle follow/unfollow status for users with persistence across app sessions
- **Responsive Design**: Adaptive layout (2 columns in portrait, 3 in landscape)
- **Image Caching**: Efficient image loading with in-memory caching
- **Badge Display**: User reputation and badge counts (gold, silver, bronze)

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository
2. Open `Users.xcodeproj` in Xcode
3. Build and run the project (⌘R)

No external dependencies required beyond the internal modules.

## Architecture

### MVVM Pattern
The app follows the Model-View-ViewModel architecture:
- **Models**: `User` - Decodable data structures
- **Views**: `UserCell`, `UsersCollectionViewController` - UI components
- **ViewModels**: `UsersViewModel` - Business logic and state management

### Dependency Injection
Uses a `DependencyContainer` pattern instead of singletons for better testability:
```swift
DependencyContainer
├── NetworkService
├── StorageService
├── FollowService
├── Logger
└── Analytics
```

### Key Technical Decisions

#### 1. Storage Architecture
- Protocol-based `StorageService` wrapping `UserDefaults`

#### 2. Follow State Management
- In-memory cache with automatic persistence via `didSet` preventing race conditions from reading UserDefaults on every access

#### 3. Image Loading
- Actor-based thread-safe image caching `ImageLoader` with NSCache

## Project Structure

```
Users/
├── Features/
│   ├── MainViewController.swift
│   └── Users/
│       ├── Model/
│       │   └── Users.swift
│       ├── ViewModel/
│       │   ├── UsersViewModel.swift
│       │   └── FollowService.swift
│       ├── Views/
│       │   └── UserCell.swift
│       └── ViewController/
│           └── UsersCollectionViewController.swift
├── Services/
│   ├── ImageLoader.swift
│   └── StorageService.swift
└── DependencyContainer.swift

Modules/
├── NetworkLibrary/
├── LoggerLibrary/
└── AnalyticsLibrary/
```

## Testing

The project includes comprehensive unit tests:
- `UsersViewModelTests`: Network requests, error handling, follow integration
- `FollowServiceTests`: Follow/unfollow logic, persistence, edge cases
- `StorageServiceTests`: Save/load operations, type safety

## Code Quality

- **SwiftLint**: Enforces consistent code style (zero violations)
- **Protocol-Oriented**: All services use protocols for testability
