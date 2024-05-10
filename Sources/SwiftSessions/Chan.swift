import Foundation
import AsyncAlgorithms

/// Represents a communication channel that enforces session types
///   - A: The type of messages that can be sent on the channel.
///   - B: The type of messages that can be received on the channel.
final class Chan<A, B> {
    
    /// Underlying asynchronous channel for communication.
    let channel: AsyncChannel<AnyObject>
    
    /// Initializes a new channel with the given asynchronous channel.
    /// - Parameter channel: The underlying asynchronous channel for communication.
    init(channel: AsyncChannel<AnyObject>) {
        self.channel = channel
    }
    
    /// Creates a new session with two dual channels and executes the provided closure on the secondary channel
    /// - Parameter closure: The closure to be executed on the secondary channel of type `Chan<B, A>`
    /// - Returns: The primary channel of type `Chan<A, B>`
    static func create(_ closure: @escaping (_: Chan<B, A>) async -> Void) async -> Chan<A, B> {
        let channel: AsyncChannel<AnyObject> = AsyncChannel()
        let c1 = Chan<A, B>(channel: channel)
        let c2 = Chan<B, A>(channel: channel)
        Task {
            await closure(c2)
        }
        return c1
    }
    
    /// Sends a message of type `A` on the channel and returns the continuation channel
    /// - Parameters:
    ///   - payload: The payload to be sent on the channel.
    ///   - chan: The channel on which the payload is sent.
    /// - Returns: The continuation channel
    static func send<A, B, C>(_ payload: A, on chan: consuming Chan<(A, Chan<B, C>), Empty>) async -> Chan<C, B> {
        await chan.channel.send(payload as AnyObject)
        return Chan<C, B>(channel: chan.channel)
    }
    
    /// Receives a message from the channel and returns it along with the continuation channel.
    /// - Parameter chan: The channel from which the message is received.
    /// - Returns: A tuple containing the received message and the continuation channel.
    static func recv<A, B, C>(from chan: consuming Chan<Empty, (A, Chan<B, C>)>) async -> (A, Chan<B, C>) {
        let msg = await chan.channel.first(where: { _ in true })!
        return (msg as! A, Chan<B, C>(channel: chan.channel))
    }
    
    /// Closes the channel, indicating the end of communication.
    /// - Parameter channel: The channel to be closed.
    static func close(_ channel: consuming Chan<Empty, Empty>) {
        return
    }
    
}
