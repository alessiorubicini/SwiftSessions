//
//  StandardTests.swift
//
//
//  Created by Alessio Rubicini on 04/05/24.
//

import Foundation
import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class StandardTests: XCTestCase {
    
    /// This test verifies the library behavior with a standard communication between two processess
    /// using the closure continuation-passing coding style
    func testIsEvenWithClosures() async {
        await Session.create { c in
            // One side of the communication channel
            await Session.recv(from: c) { num, c in
                await Session.send(num % 2 == 0, on: c) { c in
                    await Session.close(c)
                }
            }
        } _: { c in
            // Another side of the communication channel
            await Session.send(42, on: c) { c in
                await Session.recv(from: c) { isEven, c in
                    await Session.close(c)
                    assert(isEven == true)
                }
            }   
        }
    }
    
    /// This test verifies the library behavior with a standard communication between two processess
    /// using the channel passing coding style
    func testIsEvenWithPassing() async {
        typealias Communication = Channel<Empty, (Int, Channel<(Bool, Channel<Empty, Empty>), Empty>)>
        
        // One side of the communication channel
        let c = await Session.create { (c: Communication) in
            let (num, c1) = await Session.recv(from: c)
            let c2 = await Session.send(num % 2 == 0, on: c1)
            await Session.close(c2)
        }
        
        // Another side of the communication channel
        let c1 = await Session.send(42, on: c)
        let (isEven, c2) = await Session.recv(from: c1)
        await Session.close(c2)
        
        assert(isEven == true)
    }
    
    /// This test verifies the library behavior with a standard communication between two processess
    /// using the client/server architecture style
    func testIsEvenWithClientServer() async {
        // Server side
        let s = await Server { c in
            await Session.recv(from: c) { num, c in
                await Session.send(num % 2 == 0, on: c) { c in
                    await Session.close(c)
                }
            }
        }
        
        // Client side
        let _ = await Client(for: s) { c in
            await Session.send(42, on: c) { c in
                await Session.recv(from: c) { isEven, c in
                    await Session.close(c)
                    assert(isEven == true)
                }
            }
        }
        
        // Another client
        let _ = await Client(for: s) { c in
            await Session.send(3, on: c) { c in
                await Session.recv(from: c) { isEven, c in
                    await Session.close(c)
                    assert(isEven == false)
                }
            }
        }
    }
}
