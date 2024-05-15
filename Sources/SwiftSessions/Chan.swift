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
    
    /// Closes the channel, indicating the end of communication.
    /// - Parameter channel: The channel to be closed.
    static func close(_ channel: consuming Chan<Empty, Empty>) {
        return
    }
    
    // MARK: - Version without closures
    
    /// Sends a message on the channel and returns the continuation channel
    /// - Parameters:
    ///   - payload: The payload to be sent on the channel.
    ///   - chan: The channel on which the payload is sent.
    /// - Returns: The continuation channel
    static func send<C, D, E>(_ payload: C, on chan: consuming Chan<(C, Chan<D, E>), Empty>) async -> Chan<E, D> {
        await chan.channel.send(payload as AnyObject)
        return Chan<E, D>(channel: chan.channel)
    }
    
    /// Receives a message from the channel and returns it along with the continuation channel.
    /// - Parameter chan: The channel from which the message is received.
    /// - Returns: A tuple containing the received message and the continuation channel.
    static func recv<C, D, E>(from chan: consuming Chan<Empty, (C, Chan<D, E>)>) async -> (C, Chan<D, E>) {
        let msg = await chan.channel.first(where: { _ in true })!
        return (msg as! C, Chan<D, E>(channel: chan.channel))
    }
    
    
    // MARK: - Version with closures
    
    /// Sends a message on the channel and invokes the specified closure upon completion.
    /// - Parameters:
    ///   - payload: The payload to be sent on the channel.
    ///   - chan: The channel on which the payload is sent.
    ///   - continuation: A closure to be invoked after the send operation completes.
    ///                    This closure receives the continuation channel for further communication.
    static func send<C, D, E>(_ payload: C, on chan: consuming Chan<(C, Chan<D, E>), Empty>, continuation: @escaping (Chan<E, D>) async -> Void) async {
        await chan.channel.send(payload as AnyObject)
        await continuation(Chan<E, D>(channel: chan.channel))
    }
    
    /// Receives a message from the channel and invokes the specified closure upon completion.
    /// - Parameters:
    ///   - chan: The channel from which the message is received.
    ///   - continuation: A closure to be invoked after the receive operation completes.
    ///                    This closure receives the received message and the continuation channel.
    static func recv<C, D, E>(from chan: consuming Chan<Empty, (C, Chan<D, E>)>, continuation: @escaping ((C, Chan<D, E>)) async -> Void) async {
        let msg = await chan.channel.first(where: { _ in true })!
        await continuation((msg as! C, Chan<D, E>(channel: chan.channel)))
    }
    
}
