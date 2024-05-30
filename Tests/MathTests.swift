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
        let s = await Server { c in
            await Session.offer(on: c) { c in
                
                // Basic arithmetic operations
                await Session.offer(on: c) { c in
                    // Addition
                    await Session.recv(from: c) { num1, c in
                        await Session.recv(from: c) { num2, c in
                            let result: Int = num1 + num2
                            await Session.send(result, on: c) { c in
                                await Session.close(c)
                            }
                        }
                    }
                } or: { c in
                    // Substraction
                    await Session.recv(from: c) { num1, c in
                        await Session.recv(from: c) { num2, c in
                            let result: Int = num1 - num2
                            await Session.send(result, on: c) { c in
                                await Session.close(c)
                            }
                        }
                    }
                }
                
            } or: { c in
                
                // Logarithms operations
                await Session.offer(on: c) { c in
                    // Natural logarithm
                    await Session.recv(from: c) { (number: Double, c) in
                        let commonLogarithm = log(number)
                        await Session.send(commonLogarithm, on: c) { c in
                            await Session.close(c)
                        }
                    }
                } or: { c in
                    // Common logarithm
                    await Session.recv(from: c) { (number: Double, c) in
                        let commonLogarithm = log10(number)
                        await Session.send(commonLogarithm, on: c) { c in
                            await Session.close(c)
                        }
                    }
                }
                
            }

        }
        
        // A client that uses the addition operation provided by the server
        let _ = await Client(for: s) { c in
            // Choose Basic arithmetic operations
            await Session.left(c) { c in
                // Choose addition operation
                await Session.left(c) { c in
                    await Session.send(5, on: c) { c in
                        await Session.send(5, on: c) { c in
                            await Session.recv(from: c) { result, c in
                                await Session.close(c)
                                assert(result == 10)
                            }
                        }
                    }
                }
            }
        }
        
        // A client that uses the common logarithm operation provided by the server
        let _ = await Client(for: s) { c in
            // Chooses logarithms operations
            await Session.right(c) { c in
                // Chooses common logarithm
                await Session.right(c) { c in
                    let number: Double = 100.0 // Approximation of e
                    await Session.send(number, on: c) { c in
                        await Session.recv(from: c) { result, c in
                            await Session.close(c)
                            assert(result == 2.0)
                        }
                    }
                }
            }
        }
    }

}
