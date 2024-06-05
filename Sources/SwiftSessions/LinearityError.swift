//
//  LinearityError.swift
//
//
//  Created by Alessio Rubicini on 03/06/24.
//

import Foundation

/// An error involving linearity violations
enum LinearityError<A, B>: Error, LocalizedError {
    
    /// Thrown when a communication channel is consumed twice
    case channelConsumedTwice(_ channel: Channel<A, B>)
    
    /// Thrown when a communication channel is not consumed
    case channelNotConsumed(_ channel: Channel<A, B>)
    
    /// Thrown in all other cases
    case unexpected
    
    /// String descrition of the error
    public var errorDescription: String? {
        switch self {
        case .channelConsumedTwice(let c):
            return "\(c.description) was consumed twice."
        case .channelNotConsumed(let c):
            return "\(c.description) was not consumed."
        case .unexpected:
            return "An unexpected error occurred."
        }
    }
    
}
