//
//  LoopTests.swift
//
//
//  Created by Alessio Rubicini on 27/05/24.
//

import Foundation
import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class LoopTests: XCTestCase {
    
    func testSumWithLoop() async {
        var sum = 0
        let numbers = [1, 5, 22, 42, 90]
        
        let s = await Server { c in
            await Session.recv(from: c) { num, c in
                sum += num
                await Session.close(c)
            }
        }
        
        for number in numbers {
            let _ = await Client(for: s) { c in
                await Session.send(number, on: c) { c in
                    await Session.close(c)
                }
            }
        }
        
        try! await Task.sleep(for: .seconds(2))
        assert(sum == 160)
    }
    
}
