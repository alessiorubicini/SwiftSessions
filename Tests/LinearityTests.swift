//
//  LinearityChecks.swift
//
//
//  Created by Alessio Rubicini on 30/05/24.
//

import Foundation
import Foundation
import AsyncAlgorithms
import XCTest
@testable import SwiftSessions

final class LinearityTests: XCTestCase {

    /// This test aims to verify the library's behavior in situations of linearity violation.
    /// In this particular case, the violation is represented by the reuse of a channel.
    func testLinearityViolation1() async {
        await Session.create { c in
            await Session.recv(from: c) { num, c1 in
                await Session.send(num % 2 == 0, on: c1) { c2 in
                    // Using channel c1 again
                    await Session.send(false, on: c1) { c3 in
                        await Session.close(c2)
                    }
                }
            }
        } _: { c in
            await Session.send(42, on: c) { c1 in
                await Session.recv(from: c1) { isEven, c2 in
                    await Session.close(c2)
                }
            }
        }
    }
    
    /// This test aims to verify the library's behavior in situations of linearity violation.
    /// In this particular case, the violation is represented by the missing use of a channel.
    func testLinearityViolation2() async {
        await Session.create { c in
            await Session.recv(from: c) { num, c1 in
                await Session.send(num % 2 == 0, on: c1) { c2 in
                    await Session.close(c2)
                }
            }
        } _: { c in
            await Session.send(42, on: c) { c1 in
                // Not using channel c
            }
        }
    }

}
