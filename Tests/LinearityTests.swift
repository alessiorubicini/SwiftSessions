//
//  LinearityTests.swift
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
    /// In this particular case, the violation is represented by the reuse of an endpoint.
    ///
    /// Should throw a fatal error saying `Endpoint<(Bool, Endpoint<Empty, Empty>), Empty> was consumed twice.`
    func testLinearityViolation1() async {
        await Session.create { e in
            await Session.recv(from: e) { num, e1 in
                await Session.send(num % 2 == 0, on: e1) { e2 in
                    Session.close(e2)
                    
                    // Using endpoint e1 again
                    // This is a linearity violation
                    await Session.send(false, on: e1) { e3 in
                        Session.close(e3)
                    }
                }
            }
        } _: { e in
            await Session.send(42, on: e) { e1 in
                await Session.recv(from: e1) { (isEven: Bool, e2) in
                    Session.close(e2)
                }
            }
        }
    }
    
    /// This test aims to verify the library's behavior in situations of linearity violation.
    /// In this particular case, the violation is represented by the missing use of an endpoint.
    ///
    /// Should throw a fatal error saying `Endpoint Endpoint<Empty, (Bool, Endpoint<Empty, Empty>)> was not consumed.`
    func testLinearityViolation2() async {
        await Session.create { e in
            await Session.recv(from: e) { num, e in
                await Session.send(num % 2 == 0, on: e) { e in
                    Session.close(e)
                }
            }
        } _: { e in
            await Session.send(42, on: e) { e1 in
                // Not using endpoint e1
                // This is a linearity violation
            }
        }
    }

}
