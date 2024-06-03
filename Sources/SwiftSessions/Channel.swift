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
///   - `A`: The type of messages that can be sent on the channel.
///   - `B`: The type of messages that can be received on the channel.
public final class Channel<A, B>: @unchecked Sendable {
    
    /// Underlying asynchronous channel for communication.
    public let asyncChannel: AsyncChannel<Sendable>
    
    /// Determines if the channel has been used or not.
    private var isUsed: Bool = false
    
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
    public func close() {
        markAsUsed()
        asyncChannel.finish()
    }
    
    private func markAsUsed() {
        DispatchQueue.channelMutatingLock.sync {
            isUsed = true
        }
    }
    
    public func hasBeenUsed() -> Bool {
        return isUsed
    }
    
    /// A description of the channel, including the types `A` and `B`.
    public var description: String {
        "Channel<\(A.self), \(B.self)>"
    }
    
}

extension Channel where A == Empty {
    
    /// Receives an element from the async channel
    /// - Returns: the element received
    func recv() async throws -> Sendable {
        guard !isUsed else {
            close()
            throw LinearityError.channelUsedTwice(self)
        }
        markAsUsed()
        return await asyncChannel.first(where: { _ in true })!
    }
    
}

extension Channel where B == Empty {
    
    /// Sends the given element on the async channel
    /// - Parameter element: the element to be sent
    func send(_ element: Sendable) async throws {
        guard !isUsed else {
            close()
            throw LinearityError.channelUsedTwice(self)
        }
        markAsUsed()
        await asyncChannel.send(element)
    }
    
}
