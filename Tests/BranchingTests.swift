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
        let e = await Session.create { e in
            await Session.offer(on: e) { e in
                await Session.recv(from: e) { num1, e in
                    await Session.recv(from: e) { num2, e in
                        let sum: Int = num1 + num2
                        await Session.send(sum, on: e) { e in
                            Session.close(e)
                        }
                    }
                }
            } or: { e in
                await Session.recv(from: e) { num, e in
                    var result = 1
                    for i in 1...num {
                        result *= i
                    }
                    await Session.send(result, on: e) { e in
                        Session.close(e)
                    }
                }
            }

        }
        
        // Another side of the communication channel
        await Session.left(e) { e in
            await Session.send(2, on: e) { e in
                await Session.send(3, on: e) { e in
                    await Session.recv(from: e) { result, e in
                        Session.close(e)
                        assert(result == 5)
                    }
                }
            }
        }
    }
    
    func testFactorialWithBranching() async {
        // One side of the communication channel
        let e = await Session.create { e in
            await Session.offer(on: e) { e in
                await Session.recv(from: e) { num1, e in
                    await Session.recv(from: e) { num2, e in
                        let sum: Int = num1 + num2
                        await Session.send(sum, on: e) { e in
                            Session.close(e)
                        }
                    }
                }
            } or: { e in
                await Session.recv(from: e) { num, e in
                    var result = 1
                    for i in 1...num {
                        result *= i
                    }
                    await Session.send(result, on: e) { e in
                        Session.close(e)
                    }
                }
            }

        }
        
        // Another side of the communication channel
        await Session.right(e) { e in
            await Session.send(3, on: e) { e in
                await Session.recv(from: e) { result, e in
                    Session.close(e)
                    assert(result == 6)
                }
            }
        }
    }
    
}
