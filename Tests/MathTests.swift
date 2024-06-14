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

    func testMathServer1() async {
        
        // A server that provides two groups of mathematical operations:
        // - basic arithmetic operations
        // - logarithms operations
        let s = await Server { e in
            await Session.offer(on: e) { e in
                
                // Basic arithmetic operations
                await Session.offer(on: e) { e in
                    // Addition
                    await Session.recv(from: e) { num1, e in
                        await Session.recv(from: e) { num2, e in
                            let result: Int = num1 + num2
                            await Session.send(result, on: e) { e in
                                Session.close(e)
                            }
                        }
                    }
                } or: { e in
                    // Substraction
                    await Session.recv(from: e) { num1, e in
                        await Session.recv(from: e) { num2, e in
                            let result: Int = num1 - num2
                            await Session.send(result, on: e) { e in
                                Session.close(e)
                            }
                        }
                    }
                }
                
            } or: { e in
                
                // Logarithms operations
                await Session.offer(on: e) { e in
                    // Natural logarithm
                    await Session.recv(from: e) { (number: Double, e) in
                        let commonLogarithm = log(number)
                        await Session.send(commonLogarithm, on: e) { e in
                            Session.close(e)
                        }
                    }
                } or: { e in
                    // Common logarithm
                    await Session.recv(from: e) { (number: Double, e) in
                        let commonLogarithm = log10(number)
                        await Session.send(commonLogarithm, on: e) { e in
                            Session.close(e)
                        }
                    }
                }
                
            }
        }
        
        // A client that uses the addition operation provided by the server
        let _ = await Client(for: s) { e in
            // Choose Basic arithmetic operations
            await Session.left(e) { e in
                // Choose addition operation
                await Session.left(e) { e in
                    await Session.send(5, on: e) { e in
                        await Session.send(5, on: e) { e in
                            await Session.recv(from: e) { result, e in
                                Session.close(e)
                                assert(result == 10)
                            }
                        }
                    }
                }
            }
        }
        
        // A client that uses the common logarithm operation provided by the server
        let _ = await Client(for: s) { e in
            // Chooses logarithms operations
            await Session.right(e) { e in
                // Chooses common logarithm
                await Session.right(e) { e in
                    let number: Double = 100.0 // Approximation of e
                    await Session.send(number, on: e) { e in
                        await Session.recv(from: e) { result, e in
                            Session.close(e)
                            assert(result == 2.0)
                        }
                    }
                }
            }
        }
    }

}
