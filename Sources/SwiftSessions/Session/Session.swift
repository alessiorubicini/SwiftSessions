//
//  Session.swift
//
//
//  Created by Alessio Rubicini on 16/05/24.
//

import Foundation
import AsyncAlgorithms

/// A utility class for implementing session types based communications using channels
class Session {
    
    /// Creates a new session with two dual channels and executes the provided closure on the secondary channel
    /// - Parameter closure: The closure to be executed on the secondary channel of type `Chan<B, A>`
    /// - Returns: The primary channel of type `Chan<A, B>`
    static func create<A, B>(_ closure: @escaping (_: Channel<B, A>) async -> Void) async -> Channel<A, B> {
        let channel: AsyncChannel<Sendable> = AsyncChannel()
        let c1 = Channel<A, B>(channel: channel)
        let c2 = Channel<B, A>(channel: channel)
        Task {
            await closure(c2)
        }
        return c1
    }
    
    /// Creates a new session with two dual channels and returns them as a tuple
    ///
    /// This method creates a pair of dual channels of types `Channel<A, B>` and `Channel<B, A>`.
    /// These channels are linked such that any message sent on one can be received on the other.
    ///
    /// - Returns: A tuple containing two channels: the first of type `Channel<A, B>` and the second of type `Channel<B, A>`.
    static func create<A, B>() -> (Channel<A, B>, Channel<B, A>) {
        let channel: AsyncChannel<Sendable> = AsyncChannel()
        let c1 = Channel<A, B>(channel: channel)
        let c2 = Channel<B, A>(channel: channel)
        return (c1, c2)
    }
    
    /// Creates a new session with two dual channels and executes the provided closures on each channel
    ///
    /// This method initializes a pair of dual channels and concurrently executes the provided closures.
    /// The first closure operates on the secondary channel of type `Channel<B, A>`, while the second closure
    /// operates on the primary channel of type `Channel<A, B>`.
    ///
    /// - Parameters:
    ///   - sideOne: The closure to be executed on the secondary channel of type `Channel<B, A>`.
    ///   - sideTwo: The closure to be executed on the primary channel of type `Channel<A, B>`.
    static func create<A, B>(_ sideOne: @escaping (_: Channel<B, A>) async -> Void, _ sideTwo: @escaping (_: Channel<A, B>) async -> Void) async {
        let channel: AsyncChannel<Sendable> = AsyncChannel()
        let channel1 = Channel<A, B>(channel: channel)
        let channel2 = Channel<B, A>(channel: channel)
        Task {
            await sideOne(channel2)
        }
        Task {
            await sideTwo(channel1)
        }
    }
    
    /// Closes the channel, indicating the end of communication.
    /// - Parameter channel: The channel to be closed.
    static func close(_ channel: Channel<Empty, Empty>) {
        channel.close()
    }
    
}
