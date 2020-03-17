import XCTest
@testable import SwiftSDL2Testt

final class SwiftSDL2TesttTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftSDL2Testt().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
