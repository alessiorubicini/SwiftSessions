import Foundation
import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class SwiftSessionsTests: XCTestCase {
    func testIsEven() async {
        // One side of the communication channel
        let c = await Session.create { c in
            await Session.recv(from: c) { num, c in
                await Session.send(num % 2 == 0, on: c) { c in
                    Session.close(c)
                }
            }
        }
        
        // Another side of the communication channel
        await Session.send(42, on: c) { c in
            await Session.recv(from: c) { isEven, c in
                Session.close(c)
                assert(isEven == true)
            }
        }
    }
    
    func testSumAndFactorialWithBranching() async {
        // One side of the communication channel
        let c = await Session.create { c in
            await Session.branch(from: c) { label, c in
                switch label {
                case "sum":
                    await Session.recv(from: c) { (num1: Int, c) in
                        await Session.recv(from: c) { (num2: Int, c) in
                            let sum = num1 + num2
                            await Session.send(sum, on: c) { c in
                                Session.close(c)
                            }
                        }
                    }
                case "fact":
                    await Session.recv(from: c) { num, c in
                        var result = 1
                        for i in 1...num {
                            result *= i
                        }
//                        await Session.send(result, on: c) { c in
//                            Session.close(c)
//                        }
                    }
                default:
                    break
                }
            }
        }
        
        // Another side of the communication channel
        await Session.select(label: "sum", on: c) { c in
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
}
