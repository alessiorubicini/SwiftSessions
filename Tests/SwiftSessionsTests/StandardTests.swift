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
    func testIsEvenWithCreate1() async {
        // One side of the communication channel
        let c = await Session.create { c in
            await Session.recv(from: c) { num, c in
                await Session.send(num % 2 == 0, on: c) { c in
                    Session.close(c)
                }
            }
        }
        
        // Another side of the communication channel
        await Session.send(42, on: c) { c in
            await Session.recv(from: c) { isEven, c in
                Session.close(c)
                assert(isEven == true)
            }
        }
    }
    
    func testIsEvenWithCreate2() async {
        await Session.create { c in
            // One side of the communication channel
            await Session.recv(from: c) { num, c in
                await Session.send(num % 2 == 0, on: c) { c in
                    Session.close(c)
                }
            }
        } _: { c in
            // Another side of the communication channel
            await Session.send(42, on: c) { c in
                await Session.recv(from: c) { isEven, c in
                    Session.close(c)
                    assert(isEven == true)
                }
            }   
        }
    }
    
    func testIsEvenWithPassing() async {
        typealias Communication = Channel<Empty, (Int, Channel<(Bool, Channel<Empty, Empty>), Empty>)>
        
        // One side of the communication channel
        let c = await Session.create { (c: Communication) in
            let (num, c1) = await Session.recv(from: c)
            let c2 = await Session.send(num % 2 == 0, on: c1)
            Session.close(c2)
        }
        
        // Another side of the communication channel
        let c1 = await Session.send(42, on: c)
        let (isEven, c2) = await Session.recv(from: c1)
        Session.close(c2)
        
        assert(isEven == true)
    }
}
