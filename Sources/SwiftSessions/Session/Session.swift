//
//  Session.swift
//
//
//  Created by Alessio Rubicini on 16/05/24.
//

import Foundation
import AsyncAlgorithms

/// A utility class for implementing session-based communications using channels
class Session {
    
    /// Creates a new session with two dual endpoints and executes the provided closure on the secondary endpoint
    /// - Parameter closure: The closure to be executed on the secondary endpoint of type `Endpoint<B, A>`
    /// - Returns: The primary endpoint of type `Endpoint<A, B>`
    static func create<A, B>(_ closure: @escaping (_: Endpoint<B, A>) async -> Void) async -> Endpoint<A, B> {
        let channel: AsyncChannel<Sendable> = AsyncChannel()
        let e1 = Endpoint<A, B>(with: channel)
        let e2 = Endpoint<B, A>(with: channel)
        Task {
            await closure(e2)
        }
        return e1
    }
    
    /// Creates a new session with two dual endpoints and returns them as a tuple.
    ///
    /// This method creates a pair of dual endpoints of types `Endpoint<A, B>` and `Endpoint<B, A>`.
    /// These endpoint are linked such that any message sent on one can be received on the other.
    ///
    /// - Returns: A tuple containing two endpoints: the first of type `Endpoint<A, B>` and the second of type `Endpoint<B, A>`.
    static func create<A, B>() -> (Endpoint<A, B>, Endpoint<B, A>) {
        let channel: AsyncChannel<Sendable> = AsyncChannel()
        let e1 = Endpoint<A, B>(with: channel)
        let e2 = Endpoint<B, A>(with: channel)
        return (e1, e2)
    }
    
    /// Creates a new session with two dual endpoints and executes the provided closures on each endpoint
    ///
    /// This method initializes a pair of dual endpoints and concurrently executes the provided closures.
    /// The first closure operates on the secondary endpoint of type `Endpoint<B, A>`, while the second closure
    /// operates on the primary endpoint of type `Endpoint<A, B>`.
    ///
    /// - Parameters:
    ///   - sideOne: The closure to be executed on the secondary endpoint of type `Channel<B, A>`.
    ///   - sideTwo: The closure to be executed on the primary endpoint of type `Endpoint<A, B>`.
    static func create<A, B>(_ sideOne: @escaping (_: Endpoint<B, A>) async -> Void, _ sideTwo: @escaping (_: Endpoint<A, B>) async -> Void) async {
        let channel: AsyncChannel<Sendable> = AsyncChannel()
        let endpoint1 = Endpoint<A, B>(with: channel)
        let endpoint2 = Endpoint<B, A>(with: channel)
        Task {
            await sideOne(endpoint2)
        }
        Task {
            await sideTwo(endpoint1)
        }
    }
    
    /// Closes the endpoint, indicating the end of communication.
    /// - Parameter endpoint: The endpoint to close the communication.
    static func close(_ endpoint: Endpoint<Empty, Empty>) async {
        endpoint.close()
    }
    
}
