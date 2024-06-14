//
//  Session+Passing.swift
//  
//
//  Created by Alessio Rubicini on 22/05/24.
//

import Foundation

/// Extension for the Session class that provides methods using endpoint passing for continuation for session type communications.
///
/// This version of the library includes methods that allow users to send and receive messages,
/// as well as offer and select between branches using endpoint passing for continuation.
extension Session {
    
    /// Sends a message to the endpoint and returns the continuation endpoint
    /// - Parameters:
    ///   - payload: The payload to be sent to the endpoint.
    ///   - endpoint: The endpoint to which the payload is sent.
    /// - Returns: The continuation endpoint
    static func send<A, B, C>(_ payload: A, on endpoint: Endpoint<(A, Endpoint<B, C>), Empty>) async -> Endpoint<C, B> {
        await endpoint.send(payload)
        return Endpoint<C, B>(from: endpoint)
    }
    
    /// Receives a message from the endpoint and returns it along with the continuation endpoint.
    /// - Parameter endpoint: The endpoint from which the message is received.
    /// - Returns: A tuple containing the received message and the continuation endpoint.
    static func recv<A, B, C>(from endpoint: Endpoint<Empty, (A, Endpoint<B, C>)>) async -> (A, Endpoint<B, C>) {
        let msg = await endpoint.recv()
        return (msg as! A, Endpoint<B, C>(from: endpoint))
    }
    
    /// Offers a choice between two branches on the given endpoint, and returns the selected branch.
    /// - Parameter endpoint: The endpoint to which the choice is offered. This endpoint expects a value indicating the selected branch (`true` for the first branch, `false` for the second branch).
    /// - Returns: An `Or` enum value containing either the first branch endpoint of type `Endpoint<A, B>` or the second branch endpoint of type `Endpoint<C, D>`.
    static func offer<A, B, C, D>(_ endpoint: Endpoint<Empty, Or<Endpoint<A, B>, Endpoint<C, D>>>) async -> Or<Endpoint<A, B>, Endpoint<C, D>> {
        let bool = await endpoint.recv() as! Bool
        if bool {
            return Or.left(Endpoint<A, B>(from: endpoint))
        } else {
            return Or.right(Endpoint<C, D>(from: endpoint))
        }
    }
    
    /// Selects the left branch on the given endpoint and returns the continuation endpoint.
    /// - Parameter endpoint: The endpoint on which the left branch is selected.
    /// - Returns: The continuation endpoint of type `Endpoint<B, A>`.
    static func left<A, B, C, D>(_ endpoint: Endpoint<Or<Endpoint<A, B>, Endpoint<C, D>>, Empty>) -> Endpoint<B, A> {
        return Endpoint<B, A>(from: endpoint)
    }
    
    /// Selects the right branch on the given endpoint and returns the continuation endpoint.
    /// - Parameter endpoint: The endpoint on which the right branch is selected.
    /// - Returns: The continuation endpoint of type `Endpoint<D, C>`.
    static func right<A, B, C, D>(_ endpoint: Endpoint<Or<Endpoint<A, B>, Endpoint<C, D>>, Empty>) -> Endpoint<D, C> {
        return Endpoint<D, C>(from: endpoint)
    }
    
}
