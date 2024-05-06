import Foundation
import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class SwiftSessionsTests: XCTestCase {
    func test1() async throws {
        typealias Session = Chan<(Int, Chan<Bool, Empty>), Empty>
        
        let (c1, c2) = Session.create()
        
        Task {
            let continuation = Chan<Bool, Empty>(channel: c1.channel)
            await Session.send(payload: (42, continuation), on: c1)
        }

        Task {
            await Session.recv(from: c2)
        }
    }
}

