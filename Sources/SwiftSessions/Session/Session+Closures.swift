//
//  File.swift
//  
//
//  Created by Alessio Rubicini on 22/05/24.
//

import Foundation

/// Extension for the Session class that provides methods using closures for session type communications.
///
/// This version of the library includes methods that allow users to send and receive messages,
/// as well as offer and select between branches using closures for continuation.
extension Session {
    
    /// Sends a message on the channel and invokes the specified closure upon completion.
    /// - Parameters:
    ///   - payload: The payload to be sent on the channel.
    ///   - chan: The channel on which the payload is sent.
    ///   - continuation: A closure to be invoked after the send operation completes.
    ///                    This closure receives the continuation channel for further communication.
    static func send<A, B, C>(_ payload: A, on channel: Channel<(A, Channel<B, C>), Empty>, continuation: @escaping (Channel<C, B>) async -> Void) async {
        await channel.send(payload as AnyObject)
        await continuation(Channel<C, B>(channel: channel.asyncChannel))
    }
    
    /// Receives a message from the channel and invokes the specified closure upon completion.
    /// - Parameters:
    ///   - chan: The channel from which the message is received.
    ///   - continuation: A closure to be invoked after the receive operation completes.
    ///                    This closure receives the received message and the continuation channel.
    static func recv<A, B, C>(from channel: Channel<Empty, (A, Channel<B, C>)>, continuation: @escaping ((A, Channel<B, C>)) async -> Void) async {
        let msg = await channel.recv()
        await continuation((msg as! A, Channel<B, C>(channel: channel.asyncChannel)))
    }
    
    /// Offers a choice between two branches on the given channel, and executes the corresponding closure based on the selected branch.
    /// - Parameters:
    ///   - channel: The channel on which the choice is offered. This channel expects a value indicating the selected branch (`true` for the first branch, `false` for the second branch).
    ///   - side1: The closure to be executed if the first branch is selected. This closure receives a channel of type `Channel<A, B>`.
    ///   - side2: The closure to be executed if the second branch is selected. This closure receives a channel of type `Channel<C, D>`.
    static func offer<A, B, C, D>(on channel: Channel<Empty, Or<Channel<A, B>, Channel<C, D>>>, _ side1: @escaping (Channel<A, B>) async -> Void, or side2: @escaping (Channel<C, D>) async -> Void) async {
        let bool = await channel.recv() as! Bool
        
        if bool {
            await side1(Channel<A, B>(channel: channel.asyncChannel))
        } else {
            await side2(Channel<C, D>(channel: channel.asyncChannel))
        }
    }
    
    /// Selects the left branch on the given channel and executes the provided continuation closure.
    /// - Parameters:
    ///   - channel: The channel on which the left branch is selected. This channel sends a value indicating the left branch selection (`true`).
    ///   - continuation: A closure to be executed after the left branch is selected. This closure receives a channel of type `Channel<B, A>`.
    static func left<A, B, C, D>(_ channel: Channel<Or<Channel<A, B>, Channel<C, D>>, Empty>, continuation: @escaping (Channel<B, A>) async -> Void) async {
        await channel.send(true as AnyObject)
        await continuation(Channel<B, A>(channel: channel.asyncChannel))
    }
    
    /// Selects the right branch on the given channel and executes the provided continuation closure.
    /// - Parameters:
    ///   - channel: The channel on which the right branch is selected. This channel sends a value indicating the right branch selection (`false`).
    ///   - continuation: A closure to be executed after the right branch is selected. This closure receives a channel of type `Channel<D, C>`.
    static func right<A, B, C, D>(_ channel: Channel<Or<Channel<A, B>, Channel<C, D>>, Empty>, continuation: @escaping (Channel<D, C>) async -> Void) async {
        await channel.send(false as AnyObject)
        await continuation(Channel<D, C>(channel: channel.asyncChannel))
    }
    
}