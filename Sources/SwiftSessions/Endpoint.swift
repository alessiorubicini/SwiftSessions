//
//  Channel.swift
//
//
//  Created by Alessio Rubicini on 04/05/24.
//

import Foundation
import AsyncAlgorithms

/// Represents a communication endpoint that enforces session types.
///
/// This class provides a safe and linear way to communicate between different parts of your program using session types.
/// It guarantees that the endpoint is consumed only once, enforcing the expected communication pattern.
///
/// - Parameters:
///   - A: The type of messages that can be sent to the endpoint.
///   - B: The type of messages that can be received from the endpoint.
public final class Endpoint<A, B> {
    
    /// Underlying asynchronous channel for communication.
    public let asyncChannel: AsyncChannel<Sendable>
    
    /// A read-only flag indicating whether the instance has been consumed.
    ///
    /// This property is set to `true` when the endpoint is consumed and cannot be consumed again.
    private(set) var isConsumed: Bool = false
    
    /// Initializes a new endpoint with the given asynchronous channel.
    /// - Parameter channel: The underlying asynchronous channel for communication.
    init(with channel: AsyncChannel<Sendable>) {
        self.asyncChannel = channel
    }
    
    /// Initializes a new channel from an existing channel
    /// - Parameter channel: The channel from which to create the new channel.
    init<C, D>(from endpoint: Endpoint<C, D>) {
        self.asyncChannel = endpoint.asyncChannel
    }
    
    /// Deinitializes the channel and ensures it has been consumed.
    ///
    /// This method is called automatically when the channel is about to be deallocated.
    /// It verifies that the channel has been properly consumed before deallocation.
    /// If the channel has not been consumed, a fatal error is triggered, 
    /// indicating a linearity violation.
    deinit {
        if !isConsumed {
            fatalError("\(self.description) was not consumed")
        }
    }

    /// Marks the channel as consumed, ensuring linearity guarantees.
    ///
    /// This method is called internally before a primitive is executed on the channel.
    /// It throws an error if the channel has already been consumed,
    /// enforcing the linear usage pattern of session types.
    ///
    /// - Throws: a fatal error if the channel has already been consumed.
    private func consume() {
        guard !isConsumed else {
            fatalError("\(self.description) was consumed twice")
        }
        isConsumed = true
    }
    
    /// A human-readable description of the channel, including the message types.
    public var description: String {
        "Channel<\(A.self), \(B.self)>"
    }
    
}

extension Endpoint where A == Empty {
    
    /// Receives an element from the async channel
    ///
    /// This method attempts to receive a message from the channel and consumes it.
    ///
    /// - Throws: a fatal error if the channel has already been consumed.
    /// - Returns: the element received
    func recv() async -> Sendable {
        consume()
        return await asyncChannel.first(where: { _ in true })!
    }
    
}

extension Endpoint where B == Empty {
    
    /// Sends the given element on the async channel
    ///
    /// This method sends a message to the channel and consumes it.
    ///
    /// - Parameter element: the element to be sent
    /// - Throws: a fatal error if the channel has already been consumed.
    func send(_ element: Sendable) async {
        consume()
        await asyncChannel.send(element)
    }
    
}

extension Endpoint where A == Empty, B == Empty {
    
    /// Resumes all the operations on the underlying asynchronous channel
    /// and terminates the communication
    ///
    /// This method closes the channel, signaling the end of communication.
    func close() {
        consume()
        asyncChannel.finish()
    }
    
}
