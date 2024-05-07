import Foundation
import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class SwiftSessionsTests: XCTestCase {
    func test1() async {
        typealias Session = Chan<(Int, Chan<Bool, Empty>), Empty>
        var (c1, c2) = Session.create()
        
        // Invio l'intero
        let c3 = await Session.send(42, on: c1)
        
        // Ricevo l'intero e la continuazione
        let (num, send_c) = await Session.recv(from: c2)

        // Invio il booleano
        let isEven = (num % 2 == 0)
        let c4 = await Session.send(isEven, on: send_c)
        
        // Ricevo il booleano
        let b = await Session.recv(from: c4)
        print("Result: \(b)")
    }
}

