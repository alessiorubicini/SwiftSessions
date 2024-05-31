//
//  Client.swift
//
//
//  Created by Alessio Rubicini on 27/05/24.
//

import Foundation
import AsyncAlgorithms

/// Represents a client that can establish a session with a server.
public class Client {
    
    /// Initializes a new client session for the given server.
    ///
    /// - Parameters:
    ///   - server: The server instance to connect to.
    ///   - closure: The closure to execute on the client's channel after connecting.
    init<A, B>(for server: Server<A, B>, _ closure: @escaping (_: Channel<B, A>) async -> Void) async {
        let channel: AsyncChannel<Sendable> = AsyncChannel()
        let c1 = Channel<A, B>(with: channel)
        let c2 = Channel<B, A>(with: channel)
        await server.channel.send(c1)
        Task {
            await closure(c2)
        }
    }
}
