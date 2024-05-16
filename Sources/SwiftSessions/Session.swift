//
//  Session.swift
//
//
//  Created by Alessio Rubicini on 16/05/24.
//

import Foundation
import AsyncAlgorithms

class Session {
    
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
    
    /// Closes the channel, indicating the end of communication.
    /// - Parameter channel: The channel to be closed.
    static func close(_ channel: consuming Channel<Empty, Empty>) {
        return
    }
    
}
