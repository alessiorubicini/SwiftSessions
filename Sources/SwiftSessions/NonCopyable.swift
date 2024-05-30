//
//  NonCopyable.swift
//
//
//  Created by Alessio Rubicini on 30/05/24.
//

import Foundation
import AsyncAlgorithms

/// Property wrapper that ensures the wrapped object can be accessed only once.
@propertyWrapper
final class NonCopyable {
    
    private var value: AsyncChannel<Sendable>
    private var used = false
    
    var wrappedValue: AsyncChannel<Sendable> {
        get { value }
        set { value = newValue }
    }
    
    var isUsed: Bool {
        used
    }
    
    init(wrappedValue: AsyncChannel<Sendable>) {
        self.value = wrappedValue
    }
    
    func markAsUsed() {
        used = true
    }    
}
