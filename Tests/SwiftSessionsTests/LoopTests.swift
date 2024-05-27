//
//  RecursionTests.swift
//
//
//  Created by Alessio Rubicini on 27/05/24.
//

import Foundation

import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class LoopTests: XCTestCase {

    func testLoop1() async {
        // Server side
        let s = await Server { c in
            await Session.recv(from: c) { num, c in
                await Session.send(num % 2 == 0, on: c) { c in
                    Session.close(c)
                }
            }
        }
        
        // Client side
        let c = await Client(for: s) { c in
            await Session.send(42, on: c) { c in
                await Session.recv(from: c) { isEven, c in
                    Session.close(c)
                    assert(isEven == true)
                }
            }
        }
    }

}
