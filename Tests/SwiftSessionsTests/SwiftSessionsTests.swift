import Foundation
import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class SwiftSessionsTests: XCTestCase {
    func testIsEven() async {
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
}

