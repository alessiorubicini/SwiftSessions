# Swift Sessions

**SwiftSessions** is an implementation of [session types](https://en.wikipedia.org/wiki/Session_type) in Swift that enables and enforce bi-directional process communication.

## Authors and Acknowledgments

This library was developed as part of a Bachelor’s degree thesis project at University of Camerino. The project was completed by [Alessio Rubicini](https://github.com/alessiorubicini) under the supervision of professor [Luca Padovani](https://github.com/boystrange).

## Example

```swift
// One side of the communication channel
let c = await Session.create { c in
    await Session.recv(from: c) { num, c in
        await Session.send(num % 2 == 0, on: c) { c in
            Session.close(c)
        }
    }
}

// Another side of the communication channel
await Session.send(42, on: c) { c in
    await Session.recv(from: c) { isEven, c in
        Session.close(c)
    }
}
```

For additional examples, see [Tests/SwiftSessionsTests](Tests/SwiftSessionsTests)

## Installation

To integrate SwiftSessions into your project, use Swift Package Manager. 

1. Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/alessiorubicini/SwiftSessions.git", .upToNextMajor(from: "1.0.0"))
]
```

2. Then, add `SwiftSessions` to your target dependencies:

```swift
.target(
    name: "YourTargetName",
    dependencies: [
        .product(name: "SwiftSessions", package: "SwiftSessions")
    ]
)

```

## Requirements

- Swift 5.9+
- Xcode 15+
- Compatible with iOS 14.0+ / macOS 10.15+ / tvOS 14.0+ / watchOS 6.0+

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
