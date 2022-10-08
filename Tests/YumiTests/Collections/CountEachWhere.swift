import XCTest
import Yumi

final class CountEachWhereTests: XCTestCase {
    func testBasic() throws {
        XCTAssertEqual((0..<0).countEach { $0.isMultiple(of: 2) }, 0)
        XCTAssertEqual((0..<100).countEach { $0.isMultiple(of: 2) }, 50)
    }
}
