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

final class SwiftSessionsTests: XCTestCase {
    func testIsEven() async {
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
}
