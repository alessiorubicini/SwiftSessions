//
//  File.swift
//  
//
//  Created by Alessio Rubicini on 03/06/24.
//

import Foundation

/// An error involving linearity violations
enum LinearityError: Error {
    
    /// Thrown when a communication channel is used twice
    case channelUsedTwice
    
    /// Thrown in all other cases
    case unexpected
    
    public var description: String {
        switch self {
        case .channelUsedTwice:
            return "The channel was used twice."
        case .unexpected:
            return "An unexpected error occurred."
        }
    }
}
