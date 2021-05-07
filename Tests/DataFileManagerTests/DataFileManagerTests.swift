import XCTest
@testable import DataFileManager

final class DataFileManagerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DataFileManager().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
