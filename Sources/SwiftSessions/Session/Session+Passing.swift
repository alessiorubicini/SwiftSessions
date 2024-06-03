//
//  Session+Passing.swift
//  
//
//  Created by Alessio Rubicini on 22/05/24.
//

import Foundation

/// Extension for the Session class that provides methods using channel passing for continuation for session type communications.
///
/// This version of the library includes methods that allow users to send and receive messages,
/// as well as offer and select between branches using channel passing for continuation.
extension Session {
    
    /// Sends a message on the channel and returns the continuation channel
    /// - Parameters:
    ///   - payload: The payload to be sent on the channel.
    ///   - chan: The channel on which the payload is sent.
    /// - Returns: The continuation channel
    static func send<C, D, E>(_ payload: C, on channel: Channel<(C, Channel<D, E>), Empty>) async -> Channel<E, D> {
        try! await channel.send(payload)
        return Channel<E, D>(from: channel)
    }
    
    /// Receives a message from the channel and returns it along with the continuation channel.
    /// - Parameter chan: The channel from which the message is received.
    /// - Returns: A tuple containing the received message and the continuation channel.
    static func recv<C, D, E>(from channel: Channel<Empty, (C, Channel<D, E>)>) async -> (C, Channel<D, E>) {
        let msg = try! await channel.recv()
        return (msg as! C, Channel<D, E>(from: channel))
    }
    
    /// Offers a choice between two branches on the given channel, and returns the selected branch.
    /// - Parameter channel: The channel on which the choice is offered. This channel expects a value indicating the selected branch (`true` for the first branch, `false` for the second branch).
    /// - Returns: An `Or` enum value containing either the first branch channel of type `Channel<A, B>` or the second branch channel of type `Channel<C, D>`.
    static func offer<A, B, C, D>(_ channel: Channel<Empty, Or<Channel<A, B>, Channel<C, D>>>) async -> Or<Channel<A, B>, Channel<C, D>> {
        
        let bool = try! await channel.recv() as! Bool
        
        if bool {
            return Or.left(Channel<A, B>(from: channel))
        } else {
            return Or.right(Channel<C, D>(from: channel))
        }
    }
    
    /// Selects the left branch on the given channel and returns the continuation channel.
    /// - Parameter channel: The channel on which the left branch is selected. This channel sends a value indicating the left branch selection (`true`).
    /// - Returns: The continuation channel of type `Channel<B, A>`.
    static func left<A, B, C, D>(_ channel: Channel<Or<Channel<A, B>, Channel<C, D>>, Empty>) -> Channel<B, A> {
        return Channel<B, A>(from: channel)
    }
    
    /// Selects the right branch on the given channel and returns the continuation channel.
    /// - Parameter channel: The channel on which the right branch is selected. This channel sends a value indicating the right branch selection (`false`).
    /// - Returns: The continuation channel of type `Channel<D, C>`.
    static func right<A, B, C, D>(_ channel: Channel<Or<Channel<A, B>, Channel<C, D>>, Empty>) -> Channel<D, C> {
        return Channel<D, C>(from: channel)
    }
    
}
