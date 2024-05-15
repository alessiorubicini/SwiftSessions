import Foundation
import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class SwiftSessionsTests: XCTestCase {
    func testIsEvenWithoutGuard() async {
        typealias Session = Chan<(Int, Chan<(Bool, Chan<Empty, Empty>), Empty>), Empty>
        
        let c = await Session.create({ c in
            let (num, c) = await Session.recv(from: c)
            let end = await Session.send(num % 2 == 0, on: c)
            Session.close(end)
        })
        
        let c1 = await Session.send(42, on: c)
        
        let (isEven, c2) = await Session.recv(from: c1)
        
        Session.close(c2)
        
        assert(isEven == true)
    }
    
    func testWithClosures() async {
        typealias Session = Chan<(Int, Chan<(Bool, Chan<Empty, Empty>), Empty>), Empty>
        
        // One side of the communication
        let c = await Session.create { c in
            await Session.recv(from: c) { num, c in
                await Session.send(num % 2 == 0, on: c) { end in
                    Session.close(end)
                }
            }
        }
        
        // Another side of the communication
        await Session.send(42, on: c) { c in
            await Session.recv(from: c) { isEven, c in
                Session.close(c)
                assert(isEven == true)
            }
        }
    }

}

