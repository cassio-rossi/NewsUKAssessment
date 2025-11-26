# AnalyticsLibrary

A lightweight, protocol-based analytics tracking library for Swift applications, designed for easy integration with any analytics provider.

### Analytics
Type-safe event tracking with protocol-oriented design for flexible analytics integration.
- Protocol-based architecture for provider independence
- Type-safe event definitions using Swift enums
- Comprehensive event types (screen views, button taps, business events)
- Console logging for debugging in development builds
- Ready for production analytics providers (Firebase, Mixpanel, custom backend)

## 📖 Quick Examples

### Basic Usage
```swift
import AnalyticsLibrary

let analytics = Analytics()

// Track screen views
analytics.track(.screenView(name: "Accounts"))

// Track user interactions
analytics.track(.buttonTap(name: "add_to_goal", screen: "Accounts"))

// Track business events
analytics.track(.roundUpSaved(amount: 125, goalName: "Holiday Fund"))

// Track navigation
analytics.track(.navigation(from: "Accounts", to: "Goals"))

// Track errors
analytics.track(.error(type: "network", message: "Connection failed"))
```

### Shared Analytics Instance
```swift
// AppDelegate.swift
import AnalyticsLibrary

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let analytics = Analytics()
}

// Usage in view controllers
class MyViewController: UIViewController {
    private let analytics = AppDelegate.analytics

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.track(.screenView(name: "MyScreen"))
    }
}
```

### Disable Analytics
```swift
let analytics = Analytics(isEnabled: false)
// All track() calls will be no-ops
```

## 🔌 Integration with Analytics Providers

The library is designed to easily integrate with production analytics providers. Simply modify the `track(_:)` method in `Analytics.swift`:

```swift
// Example: Firebase Analytics
public func track(_ event: AnalyticsEvent) {
    guard isEnabled else { return }

    #if DEBUG
    logger.info("📊 [\(event.name)] \(formatEventData(event))")
    #endif

    // Production integration
    Analytics.logEvent(event.name, parameters: event.parameters)
}
```

```swift
// Example: Mixpanel
public func track(_ event: AnalyticsEvent) {
    guard isEnabled else { return }

    #if DEBUG
    logger.info("📊 [\(event.name)] \(formatEventData(event))")
    #endif

    // Production integration
    Mixpanel.mainInstance().track(event: event.name, properties: event.parameters)
}
```

## 📊 Event Types

The library provides these built-in event types:

- **`screenView(name:)`** - Track screen appearances
- **`buttonTap(name:screen:)`** - Track user interactions with UI elements
- **`roundUpSaved(amount:goalName:)`** - Track business events
- **`navigation(from:to:)`** - Track navigation between screens
- **`error(type:message:)`** - Track error occurrences

You can easily extend `AnalyticsEvent` to add custom events specific to your application.

## 🎯 Design Philosophy

- **Protocol-Oriented**: Easy to mock for testing, swap implementations
- **Type-Safe**: Compile-time safety for event names and parameters
- **Provider-Agnostic**: Works with any analytics backend
- **Zero Dependencies**: No external dependencies required
- **Debug-Friendly**: Console logging in development builds
