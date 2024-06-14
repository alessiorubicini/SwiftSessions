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
        await Session.create { e in
            // One side of the communication channel
            await Session.recv(from: e) { num, e in
                await Session.send(num % 2 == 0, on: e) { e in
                    await Session.close(e)
                }
            }
        } _: { e in
            // Another side of the communication channel
            await Session.send(42, on: e) { e in
                await Session.recv(from: e) { isEven, e in
                    await Session.close(e)
                    assert(isEven == true)
                }
            }   
        }
    }
    
    /// This test verifies the library behavior with a standard communication between two processess
    /// using the channel passing coding style
    func testIsEvenWithPassing() async {
        typealias Protocol = Endpoint<Empty, (Int, Endpoint<(Bool, Endpoint<Empty, Empty>), Empty>)>
        
        // One side of the communication channel
        let e = await Session.create { (e: Protocol) in
            let (num, e1) = await Session.recv(from: e)
            let e2 = await Session.send(num % 2 == 0, on: e1)
            await Session.close(e2)
        }
        
        // Another side of the communication channel
        let e1 = await Session.send(42, on: e)
        let (isEven, e2) = await Session.recv(from: e1)
        await Session.close(e2)
        
        assert(isEven == true)
    }
    
    /// This test verifies the library behavior with a standard communication between two processess
    /// using the client/server architecture style
    func testIsEvenWithClientServer() async {
        // Server side
        let s = await Server { e in
            await Session.recv(from: e) { num, e in
                await Session.send(num % 2 == 0, on: e) { e in
                    await Session.close(e)
                }
            }
        }
        
        // Client side
        let _ = await Client(for: s) { e in
            await Session.send(42, on: e) { e in
                await Session.recv(from: e) { isEven, e in
                    await Session.close(e)
                    assert(isEven == true)
                }
            }
        }
        
        // Another client
        let _ = await Client(for: s) { e in
            await Session.send(3, on: e) { e in
                await Session.recv(from: e) { isEven, e in
                    await Session.close(e)
                    assert(isEven == false)
                }
            }
        }
    }
}
