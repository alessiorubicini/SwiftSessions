//
//  Empty.swift
//
//
//  Created by Alessio Rubicini on 04/05/24.
//

import Foundation

/// Represents an empty type used for parts of a channel where no message sending or receiving is allowed.
enum Empty {
    
}

class Container<A> {
    static func foo<A>(item: A) {
        print(item)
    }
}
