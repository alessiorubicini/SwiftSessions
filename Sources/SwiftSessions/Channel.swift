import Foundation
import AsyncAlgorithms

/// Represents a communication channel that enforces session types
///   - A: The type of messages that can be sent on the channel.
///   - B: The type of messages that can be received on the channel.
final class Channel<A, B> {
    
    /// Underlying asynchronous channel for communication.
    let asyncChannel: AsyncChannel<AnyObject>
    
    /// Initializes a new channel with the given asynchronous channel.
    /// - Parameter channel: The underlying asynchronous channel for communication.
    init(channel: AsyncChannel<AnyObject>) {
        self.asyncChannel = channel
    }
    
    /// Sends the given element on the async channel
    /// - Parameter element: the element to be sent
    public func send(_ element: AnyObject) async {
        await asyncChannel.send(element)
    }
    
    /// Receives an element from the async channel
    /// - Returns: the element received
    public func recv() async -> AnyObject {
        return await asyncChannel.first(where: { _ in true })!
    }
    
    
}
