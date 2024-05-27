//
//  Server.swift
//
//
//  Created by Alessio Rubicini on 27/05/24.
//

import Foundation
import AsyncAlgorithms

class Server<A, B> {
    let channel: AsyncChannel<Sendable>
    
    init(_ closure: @escaping (_: Channel<A, B>) async -> Void) async {
        // Creates a public channel to receive sessions request
        channel = AsyncChannel()
        // Waits and listen for session requests
        Task {
            while true {
                for await message in channel {
                    let channel = message as! Channel<A, B>
                    // Runs the server protocol on the received channel
                    Task {
                        await closure(channel)
                    }
                }
            }
        }
    }
}
