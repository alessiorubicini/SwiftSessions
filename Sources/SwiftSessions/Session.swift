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
    
    // MARK: - Channel creation
    
    /// Creates a new session with two dual channels and executes the provided closure on the secondary channel
    /// - Parameter closure: The closure to be executed on the secondary channel of type `Chan<B, A>`
    /// - Returns: The primary channel of type `Chan<A, B>`
    static func create<A, B>(_ closure: @escaping (_: Channel<B, A>) async -> Void) async -> Channel<A, B> {
        let channel: AsyncChannel<AnyObject> = AsyncChannel()
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
        let channel: AsyncChannel<AnyObject> = AsyncChannel()
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
        let channel: AsyncChannel<AnyObject> = AsyncChannel()
        let channel1 = Channel<A, B>(channel: channel)
        let channel2 = Channel<B, A>(channel: channel)
        Task {
            await sideOne(channel2)
            await sideTwo(channel1)
        }
    }
    
    
    // MARK: - Version with closures
    
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
    
    static func offer<A, B, C, D>(_ channel: Channel<Empty, Or<Channel<A, B>, Channel<C, D>>>, continuation: @escaping (Or<Channel<A, B>, Channel<C, D>>) async -> Void) async {
        let branch = await channel.recv() as! Or<Channel<A, B>, Channel<C, D>>
        await continuation(branch)
    }
    
    static func left<A, B, C, D>(_ channel: Channel<Or<Channel<A, B>, Channel<C, D>>, Empty>, continuation: @escaping (Channel<B, A>) async -> Void) async {
        await continuation(Channel<B, A>(channel: channel.asyncChannel))
    }
    
    static func right<A, B, C, D>(_ channel: Channel<Or<Channel<A, B>, Channel<C, D>>, Empty>, continuation: @escaping (Channel<D, C>) async -> Void) async {
        await continuation(Channel<D, C>(channel: channel.asyncChannel))
    }
    
    
    // MARK: - Version with channel passing
    
    /// Sends a message on the channel and returns the continuation channel
    /// - Parameters:
    ///   - payload: The payload to be sent on the channel.
    ///   - chan: The channel on which the payload is sent.
    /// - Returns: The continuation channel
    static func send<C, D, E>(_ payload: C, on chan: Channel<(C, Channel<D, E>), Empty>) async -> Channel<E, D> {
        await chan.send(payload as AnyObject)
        return Channel<E, D>(channel: chan.asyncChannel)
    }
    
    /// Receives a message from the channel and returns it along with the continuation channel.
    /// - Parameter chan: The channel from which the message is received.
    /// - Returns: A tuple containing the received message and the continuation channel.
    static func recv<C, D, E>(from chan: Channel<Empty, (C, Channel<D, E>)>) async -> (C, Channel<D, E>) {
        let msg = await chan.recv()
        return (msg as! C, Channel<D, E>(channel: chan.asyncChannel))
    }
    
    static func offer<A, B, C, D>(_ channel: Channel<Empty, Or<Channel<A, B>, Channel<C, D>>>) async -> Or<Channel<A, B>, Channel<C, D>> {
        let branch = await channel.recv() as! Or<Channel<A, B>, Channel<C, D>>
        
        switch branch {
        case .left(let c):
            return .left(Channel<A, B>(channel: channel.asyncChannel))
        case .right(let c):
            return .right(Channel<C, D>(channel: channel.asyncChannel))
        }
    }
    
    static func left<A, B, C, D>(_ channel: Channel<Or<Channel<A, B>, Channel<C, D>>, Empty>) -> Channel<B, A> {
        return Channel<B, A>(channel: channel.asyncChannel)
    }
    
    static func right<A, B, C, D>(_ channel: Channel<Or<Channel<A, B>, Channel<C, D>>, Empty>) -> Channel<D, C> {
        return Channel<D, C>(channel: channel.asyncChannel)
    }
    
    
    // MARK: - Channel closing
    
    /// Closes the channel, indicating the end of communication.
    /// - Parameter channel: The channel to be closed.
    static func close(_ channel: Channel<Empty, Empty>) {
        channel.close()
    }
    
}
