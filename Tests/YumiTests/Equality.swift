import XCTest
import Yumi

private final class Box: Equatable {
    var x: Int

    init(_ x: Int) {
        self.x = x
    }

    static func == (lhs: Box, rhs: Box) -> Bool {
        lhs.x == rhs.x
    }
}


final class EqualityTests: XCTestCase {
    func testMemoryEqual() {
        @MemoryEqual var a = Box(0)
        @MemoryEqual var b = a
        @MemoryEqual var c = Box(0)

        XCTAssertEqual($a, $b)
        XCTAssertEqual(a, c)
        XCTAssertNotEqual($a, $c)
    }

    func testAlwaysEqual() {
        @AlwaysEqual var x = 1
        @AlwaysEqual var y = 2
        XCTAssertEqual($x, $y)
    }
}
