# Swift Sessions

**SwiftSessions** is an implementation of [session types](https://en.wikipedia.org/wiki/Session_type) in Swift that enables and enforces bi-directional session-based process communication.

The library currently supports the following features:
- session type inference (only with closures)
- session types with binary branches
- dynamic linearity checking
- duality constraints on session types
- client/server architecture for session initialization

## Authors and Acknowledgments

This library was developed as part of a Bachelor’s degree thesis project at the University of Camerino. The project was completed by [Alessio Rubicini](https://github.com/alessiorubicini) under the supervision of professor [Luca Padovani](https://github.com/boystrange).

## Overview

### Programming Styles
This library offers two distinct styles for managing session types:
- **Continuation with Closures**: protocol continuations are passed as closures. This approach makes the flow of logic explicit and easy to follow within the closure context. It's particularly useful for straightforward communication sequences.
    
    ```swift
    await Session.create { c in
        // One side of the communication channel
        await Session.recv(from: c) { num, c in
            await Session.send(num % 2 == 0, on: c) { c in
                await Session.close(c)
            }
        }
    } _: { c in
        // Another side of the communication channel
        await Session.send(42, on: c) { c in
            await Session.recv(from: c) { isEven, c in
                await Session.close(c)
            }
        }   
    }
    ```
    
    - Pros: Complete type inference of the communication protocol.
	- Cons: Nested code structure.
    
- **Channel Passing for Continuation**: this style involves returning continuation channels from communication primitives. It offers greater flexibility, enabling more modular and reusable code, particularly for complex communication sequences.

    ```swift
    typealias Communication = Channel<Empty, (Int, Channel<(Bool, Channel<Empty, Empty>), Empty>)>
        
    // One side of the communication channel
    let c = await Session.create { (c: Communication) in
        let (num, c1) = await Session.recv(from: c)
        let c2 = await Session.send(num % 2 == 0, on: c1)
        await Session.close(c2)
    }

    // Another side of the communication channel
    let c1 = await Session.send(42, on: c)
    let (isEven, c2) = await Session.recv(from: c1)
    await Session.close(c2)
    ```
    
    - Pros: Simplicity, particularly for avoiding deep indentation.
	- Cons: Incomplete type inference support.

Each style provides a unique approach to handling session-based binary communication and comes with its own pros and cons. By supporting both styles, SwiftSessions allows you to choose the best approach (or use both in a hybrid way!) according to your needs and coding preferences.

For additional examples, see the [Tests](Tests) folder.
 
### Client/Server Architecture

Instead of creating disposable sessions as seen in the previous examples, you can also initialize sessions using a client/server architectural style.

A **server** is responsible for creating and managing multiple sessions that can handle a specific protocol. Many **clients** can be spawned and used with the same server to interact dually according to that defined protocol. This allows to define a protocol's side only once, and use it as many times as we want.

```swift
// Server side
let server = await Server { c in
    await Session.recv(from: c) { num, c in
        await Session.send(num % 2 == 0, on: c) { c in
            await Session.close(c)
        }
    }
}

// Client side
let c1 = await Client(for: server) { c in
    await Session.send(42, on: c) { c in
        await Session.recv(from: c) { isEven, c in
            await Session.close(c)
        }
    }
}

// You can spawn more clients here...
```
    
This architecture is useful for scenarios where multiple clients need to interact with a single server. It's also useful to implement complex protocols that involve loops and recursion.

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

- Swift 5.5+
- Xcode 13+
- Compatible with iOS 14.0+ / macOS 10.15+ / tvOS 14.0+ / watchOS 6.0+

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
