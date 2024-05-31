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
    let publicChannel: AsyncChannel<Sendable>
    
    /// Initializes a new server instance that listens for client sessions.
    ///
    /// - Parameter closure: The closure to execute on the server's channel for each session.
    init(_ closure: @escaping (_: Channel<A, B>) async -> Void) async {
        publicChannel = AsyncChannel()
        Task {
            while true {
                for await message in publicChannel {
                    let channel = message as! Channel<A, B>
                    Task {
                        await closure(channel)
                    }
                }
            }
        }
    }
    
    public func connect(with channel: Channel<A, B>) async {
        await publicChannel.send(channel)
    }
}
