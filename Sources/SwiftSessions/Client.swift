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
    /// - Parameters:
    ///   - server: The server instance to connect to.
    ///   - closure: The closure to execute on the client's channel after connecting.
    init<A, B>(for server: Server<A, B>, _ closure: @escaping (_: Endpoint<B, A>) async -> Void) async {
        let channel: AsyncChannel<Sendable> = AsyncChannel()
        await server.connect(with: channel)
        let c = Endpoint<B, A>(with: channel)
        Task {
            await closure(c)
        }
    }
}
