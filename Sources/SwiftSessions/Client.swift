//
//  Client.swift
//
//
//  Created by Alessio Rubicini on 27/05/24.
//

import Foundation
import AsyncAlgorithms

class Client {
    init<A, B>(for server: Server<A, B>, _ closure: @escaping (_: Channel<B, A>) async -> Void) async {
        // Creates private async channel for the session
        let channel: AsyncChannel<Sendable> = AsyncChannel()
        // Creates the two dual channels
        let c1 = Channel<A, B>(channel: channel)
        let c2 = Channel<B, A>(channel: channel)
        // Sends the first channel to the server
        await server.channel.send(c1)
        // Runs the client protocol on the second channel
        Task {
            await closure(c2)
        }
    }
}
