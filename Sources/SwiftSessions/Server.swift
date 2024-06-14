//
//  Server.swift
//
//
//  Created by Alessio Rubicini on 27/05/24.
//

import Foundation
import AsyncAlgorithms

/// Represents a server that can create and handle client sessions.
public class Server<A, B> {
    
    /// The public channel for receiving session requests from clients.
    private let publicChannel: AsyncChannel<Sendable>
    
    /// Initializes a new server instance that listens for client sessions.
    /// - Parameter closure: The closure to execute on the server's channel for each session.
    init(_ closure: @escaping (_: Endpoint<A, B>) async -> Void) async {
        publicChannel = AsyncChannel()
        Task {
            while true {
                for await request in publicChannel {
                    let asyncChannel = request as! AsyncChannel<Sendable>
                    let endpoint = Endpoint<A, B>(with: asyncChannel)
                    Task {
                        await closure(endpoint)
                    }
                }
            }
        }
    }
    
    public func connect(with channel: AsyncChannel<Sendable>) async {
        await publicChannel.send(channel)
    }
}
