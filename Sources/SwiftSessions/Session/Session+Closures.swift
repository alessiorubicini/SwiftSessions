//
//  Session+Closures.swift
//
//
//  Created by Alessio Rubicini on 22/05/24.
//

import Foundation

/// Extension for the Session class that provides methods using closures for session type communications.
///
/// This version of the library includes methods that allow users to send and receive messages,
/// as well as offer and select between branches using closures for continuation.
extension Session {
    
    /// Sends a message on the channel and invokes the specified closure upon completion.
    /// - Parameters:
    ///   - payload: The payload to be sent to the endpoint.
    ///   - endpoint: The endpoint to which the payload is sent.
    ///   - continuation: A closure to be invoked after the send operation completes.
    ///                    This closure receives the continuation endpoint for further communication.
    static func send<A, B, C>(_ payload: A, on endpoint: Endpoint<(A, Endpoint<B, C>), Empty>, continuation: @escaping (Endpoint<C, B>) async -> Void) async {
        await endpoint.send(payload)
        await continuation(Endpoint<C, B>(from: endpoint))
    }
    
    /// Receives a message from the channel and invokes the specified closure upon completion.
    /// - Parameters:
    ///   - endpoint: The endpoint from which the message is received.
    ///   - continuation: A closure to be invoked after the receive operation completes.
    ///                    This closure receives the received message and the continuation endpoint.
    static func recv<A, B, C>(from endpoint: Endpoint<Empty, (A, Endpoint<B, C>)>, continuation: @escaping ((A, Endpoint<B, C>)) async -> Void) async {
        let msg = await endpoint.recv()
        await continuation((msg as! A, Endpoint<B, C>(from: endpoint)))
    }
    
    /// Offers a choice between two branches on the given channel, and executes the corresponding closure based on the selected branch.
    /// - Parameters:
    ///   - endpoint: The endpoint on which the choice is offered. This endpoint expects a value indicating the selected branch (`true` for the first branch, `false` for the second branch).
    ///   - side1: The closure to be executed if the first branch is selected. This closure receives a endpoint of type `Endpoint<A, B>`.
    ///   - side2: The closure to be executed if the second branch is selected. This closure receives a endpoint of type `Endpoint<C, D>`.
    static func offer<A, B, C, D>(on endpoint: Endpoint<Empty, Or<Endpoint<A, B>, Endpoint<C, D>>>, _ side1: @escaping (Endpoint<A, B>) async -> Void, or side2: @escaping (Endpoint<C, D>) async -> Void) async {
        let bool = await endpoint.recv() as! Bool
        if bool {
            await side1(Endpoint<A, B>(from: endpoint))
        } else {
            await side2(Endpoint<C, D>(from: endpoint))
        }
    }
    
    /// Selects the left branch on the given endpoint and executes the provided continuation closure.
    /// - Parameters:
    ///   - endpoint: The channel on which the left branch is selected.
    ///   - continuation: A closure to be executed after the left branch is selected. This closure receives a endpoint of type `Endpoint<B, A>`.
    static func left<A, B, C, D>(_ endpoint: Endpoint<Or<Endpoint<A, B>, Endpoint<C, D>>, Empty>, continuation: @escaping (Endpoint<B, A>) async -> Void) async {
        await endpoint.send(true)
        await continuation(Endpoint<B, A>(from: endpoint))
    }
    
    /// Selects the right branch on the given channel and executes the provided continuation closure.
    /// - Parameters:
    ///   - endpoint: The endpoint on which the right branch is selected.
    ///   - continuation: A closure to be executed after the right branch is selected. This closure receives a endpoint of type `Endpoint<D, C>`.
    static func right<A, B, C, D>(_ endpoint: Endpoint<Or<Endpoint<A, B>, Endpoint<C, D>>, Empty>, continuation: @escaping (Endpoint<D, C>) async -> Void) async {
        await endpoint.send(false)
        await continuation(Endpoint<D, C>(from: endpoint))
    }
    
}
