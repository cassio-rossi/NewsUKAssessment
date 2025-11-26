# LoggerLibrary

A comprehensive collection of Swift libraries, providing essential functionality for modern Apple platform applications.

## 📦 Available Libraries

### [Logger](Sources/LoggerLibrary/LoggerLibrary.docc/LoggerLibrary.md)
Structured logging with multiple levels, category-based filtering, and Console.app integration.
- Multiple log levels (error, warning, info, debug) with emoji indicators
- File filtering and source location tracking
- Real-time enable/disable control

## 📖 Quick Examples

### Logger
```swift
import LoggerLibrary

let logger = Logger(category: "MyApp")
logger.info("User logged in successfully")
logger.error("Failed to fetch data: \(error)")
```
