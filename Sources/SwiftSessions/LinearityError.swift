//
//  File.swift
//  
//
//  Created by Alessio Rubicini on 03/06/24.
//

import Foundation

/// An error involving linearity violations
enum LinearityError<A, B>: Error, LocalizedError {
    
    /// Thrown when a communication channel is used twice
    case channelUsedTwice(_ channel: Channel<A, B>)
    
    /// Thrown when a communication channel is not used
    case channelNotUsed(_ channel: Channel<A, B>)
    
    /// Thrown in all other cases
    case unexpected
    
    /// String descrition of the error
    public var errorDescription: String? {
        switch self {
        case .channelUsedTwice(let c):
            return "\(c.description) was used twice."
        case .channelNotUsed(let c):
            return "\(c.description) was not used"
        case .unexpected:
            return "An unexpected error occurred."
        }
    }
    
}
