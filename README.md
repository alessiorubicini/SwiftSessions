# Swift Sessions

**SwiftSessions** is an implementation of [session types](https://en.wikipedia.org/wiki/Session_type) in Swift that enables and enforces bi-directional session-based process communication.

## Overview

### Programming Styles
This library offers two distinct styles for managing session types:
- **Continuation with Closures**: closures are used to handle the next steps after sending or receiving a message. This approach makes the flow of logic explicit and easy to follow within the closure context. It's particularly useful for straightforward communication sequences. 
    
    ```swift
    await Session.create { c in
        // One side of the communication channel
        await Session.recv(from: c) { num, c in
            await Session.send(num % 2 == 0, on: c) { c in
                Session.close(c)
            }
        }
    } _: { c in
        // Another side of the communication channel
        await Session.send(42, on: c) { c in
            await Session.recv(from: c) { isEven, c in
                Session.close(c)
            }
        }   
    }
    ```
    
    The main pro of this style is that it allows complete type inference of the communication protocol, while the main con is nested code since indentation goes deeper and deeper as the protocol complexity grows.
    
- **Channel Passing for Continuation**: this style involves returning continuation channels from communication primitives. It offers greater flexibility, enabling more modular and reusable code, particularly for complex communication sequences.

    ```swift
    typealias Communication = Channel<Empty, (Int, Channel<(Bool, Channel<Empty, Empty>), Empty>)>
        
    // One side of the communication channel
    let c = await Session.create { (c: Communication) in
        let (num, c1) = await Session.recv(from: c)
        let c2 = await Session.send(num % 2 == 0, on: c1)
        Session.close(c2)
    }

    // Another side of the communication channel
    let c1 = await Session.send(42, on: c)
    let (isEven, c2) = await Session.recv(from: c1)
    Session.close(c2)
    ```
    
    The main pro of this style is code simplicity since it doesn't require indenting more and more every time a primitive is called, while the main con is missing support to complete type inference.

 Each style provides a unique approach to handling session-based binary communication, and comes with its own pros and cons. By supporting both styles, SwiftSessions allows you to choose the best approach (or both of them in a hybrid way!) according to your needs and coding preferences.
 
 For additional examples, see [Tests/SwiftSessionsTests](Tests/SwiftSessionsTests).
 
### Client/Server Architecture

While the library can be used in a straightforward and concise manner, creating disposable sessions as seen in the previous examples, it also supports a client/server architectural style.

A **server** is responsible for creating and managing multiple sessions according to a specific behavior or protocol. Many **clients** can be spawned and used with the same server to interact dually with its well-defined protocol. This allows to define a protocol's side only once, and use it as many times as we want.

```swift
// Server side
let server = await Server { c in
    await Session.recv(from: c) { num, c in
        await Session.send(num % 2 == 0, on: c) { c in
            Session.close(c)
        }
    }
}

// Client side
let c1 = await Client(for: server) { c in
    await Session.send(42, on: c) { c in
        await Session.recv(from: c) { isEven, c in
            Session.close(c)
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

- Swift 5.9+
- Xcode 15+
- Compatible with iOS 14.0+ / macOS 10.15+ / tvOS 14.0+ / watchOS 6.0+

## Authors and Acknowledgments

This library was developed as part of a Bachelor’s degree thesis project at University of Camerino. The project was completed by [Alessio Rubicini](https://github.com/alessiorubicini) under the supervision of professor [Luca Padovani](https://github.com/boystrange).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
