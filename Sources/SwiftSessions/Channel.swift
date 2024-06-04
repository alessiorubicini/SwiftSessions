//
//  Channel.swift
//
//
//  Created by Alessio Rubicini on 04/05/24.
//

import Foundation
import AsyncAlgorithms

extension DispatchQueue {
    static let channelMutatingLock = DispatchQueue(label: "channel.lock.queue")
}

/// Represents a communication channel that enforces session types.
///
/// This class provides a safe and linear way to communicate between different parts of your program using session types.
/// It guarantees that the channel is consumed only once, enforcing the expected communication pattern.
///
/// - Parameters:
///   - A: The type of messages that can be sent on the channel.
///   - B: The type of messages that can be received on the channel.
public final class Channel<A, B>: @unchecked Sendable {
    
    /// Underlying asynchronous channel for communication.
    public let asyncChannel: AsyncChannel<Sendable>
    
    /// A read-only boolean flag indicating whether the instance has been consumed.
    /// This property is set to `true` when the channel is consumed and cannot be consumed again.
    ///
    /// Once set to `true`, this property cannot be changed back to `false`.
    private(set) var isConsumed: Bool = false
    
    /// Initializes a new channel with the given asynchronous channel.
    /// - Parameter channel: The underlying asynchronous channel for communication.
    init(with channel: AsyncChannel<Sendable>) {
        self.asyncChannel = channel
    }
    
    /// Initializes a new channel from an existing channel
    /// - Parameter channel: The channel from which to create the new channel.
    init<C, D>(from channel: Channel<C, D>) {
        self.asyncChannel = channel.asyncChannel
    }

    /// Resumes all the operations on the underlying asynchronous channel
    /// and terminates the communication
    ///
    /// This method closes the channel, signaling the end of communication. Any further attempts to send or receive on the channel will result in an error.
    public func close() {
        consume()
        asyncChannel.finish()
    }
    
    /// Marks the channel as consumed, ensuring linearity guarantees.
    ///
    /// This method is called internally before a primitive is executed on the channel.
    /// It throws an error if the channel has already been consumed,
    /// enforcing the linear usage pattern of session types.
    ///
    /// - Throws: `LinearityError.channelConsumedTwice` if the channel has already been consumed.
    private func consume() {
        DispatchQueue.channelMutatingLock.sync {
            do {
                guard !isConsumed else {
                    throw LinearityError.channelConsumedTwice(self)
                }
                isConsumed = true
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    /// A human-readable description of the channel, including the message types.
    ///
    /// This property returns a string representation of the channel, specifying the types of messages it can send (`A`) and receive (`B`).
    ///
    /// - Returns: A string representation of the channel in the format "Channel<A, B>".
    public var description: String {
        "Channel<\(A.self), \(B.self)>"
    }
    
}

extension Channel where A == Empty {
    
    /// Receives an element from the async channel
    ///
    /// This method attempts to receive a message from the channel and consumes it.
    ///
    /// - Throws: `LinearityError.channelConsumedTwice` if the channel has already been consumed.
    /// - Returns: the element received
    func recv() async -> Sendable {
        consume()
        return await asyncChannel.first(where: { _ in true })!
    }
    
}

extension Channel where B == Empty {
    
    /// Sends the given element on the async channel
    ///
    /// This method sends a message to the channel and consumes it.
    ///
    /// - Parameter element: the element to be sent
    /// - Throws: `LinearityError.channelConsumedTwice` if the channel has already been consumed.
    func send(_ element: Sendable) async {
        consume()
        await asyncChannel.send(element)
    }
    
}
