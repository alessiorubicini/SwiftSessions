//
//  BranchingTests.swift
//  
//
//  Created by Alessio Rubicini on 23/05/24.
//

import Foundation
import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class BranchingTests: XCTestCase {

    func testSumWithBranching() async {
        // One side of the communication channel
        let c = await Session.create { c in
            await Session.offer(on: c) { c in
                await Session.recv(from: c) { num1, c in
                    await Session.recv(from: c) { num2, c in
                        let sum: Int = num1 + num2
                        await Session.send(sum, on: c) { c in
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
        
        // Another side of the communication channel
        await Session.left(c) { c in
            await Session.send(2, on: c) { c in
                await Session.send(3, on: c) { c in
                    await Session.recv(from: c) { result, c in
                        Session.close(c)
                        assert(result == 5)
                    }
                }
            }
        }
        
    }
    
    func testFactorialWithBranching() async {
        // One side of the communication channel
        let c = await Session.create { c in
            await Session.offer(on: c) { c in
                await Session.recv(from: c) { num1, c in
                    await Session.recv(from: c) { num2, c in
                        let sum: Int = num1 + num2
                        await Session.send(sum, on: c) { c in
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
        
        // Another side of the communication channel
        await Session.right(c) { c in
            await Session.send(3, on: c) { c in
                await Session.recv(from: c) { result, c in
                    Session.close(c)
                    assert(result == 6)
                }
            }
        }
    }
    
}
