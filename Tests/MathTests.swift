//
//  Math.swift
//  
//
//  Created by Alessio Rubicini on 30/05/24.
//

import XCTest
import Foundation
import AsyncAlgorithms
@testable import SwiftSessions

/// Examples involving math operations
final class MathTests: XCTestCase {

    func testMathServer() async {
        // A server that provides two mathematical operations: addition and factorial
        let s = await Server { c in
            await Session.offer(on: c) { c in
                await Session.recv(from: c) { num1, c in
                    await Session.recv(from: c) { num2, c in
                        let result: Int = num1 + num2
                        await Session.send(result, on: c) { c in
                            Session.close(c)
                        }
                    }
                }
            } or: { c in
                await Session.recv(from: c) { num, c in
                    var result = 1
                    for i in 1...num {
                        result *= i
                    }
                    await Session.send(result, on: c) { c in
                        Session.close(c)
                    }
                }
            }

        }
        
        // A client that uses the addition operation provided by the server
        let _ = await Client(for: s) { c in
            await Session.left(c) { c in
                await Session.send(5, on: c) { c in
                    await Session.send(5, on: c) { c in
                        await Session.recv(from: c) { result, c in
                            Session.close(c)
                            assert(result == 10)
                        }
                    }
                }
            }
        }
        
        // A client that uses the factorial operation provided by the server
        let _ = await Client(for: s) { c in
            await Session.right(c) { c in
                await Session.send(5, on: c) { c in
                    await Session.recv(from: c) { result, c in
                        Session.close(c)
                        assert(result == 120)
                    }
                }
            }
        }
    }

}
