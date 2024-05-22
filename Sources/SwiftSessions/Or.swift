//
//  Or.swift
//  
//
//  Created by Alessio Rubicini on 21/05/24.
//

import Foundation

/// Represents a binary branching point with two possible protocol choices
enum Or<A, B> {
    case left(A)
    case right(B)
}
