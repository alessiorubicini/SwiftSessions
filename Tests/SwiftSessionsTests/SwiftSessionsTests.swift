import Foundation
import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class SwiftSessionsTests: XCTestCase {
    
    func test1() async {
        typealias Session = Chan<(Int, Chan<(Bool, Chan<Empty, Empty>), Empty>), Empty>
        
        var c = await Session.create({ c in
            var (num, c) = await Session.recv(from: c)
            let end = await Session.send(num % 2 == 0, on: c)
            await Session.close(end)
        })
        
        let c1 = await Session.send(42, on: c)
        
        let (isEven, c2) = await Session.recv(from: c1)
        
        await Session.close(c2)
        
        print(isEven)
    }
}

