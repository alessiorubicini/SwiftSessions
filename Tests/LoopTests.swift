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
        
        let s = await Server { e in
            await Session.recv(from: e) { num, e in
                sum += num
                await Session.close(e)
            }
        }
        
        for number in numbers {
            let _ = await Client(for: s) { e in
                await Session.send(number, on: e) { e in
                    await Session.close(e)
                }
            }
        }
        
        try! await Task.sleep(for: .seconds(2))
        assert(sum == 160)
    }
    
}
