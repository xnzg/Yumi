import XCTest
import Yumi

final class SortedArrayTests: XCTestCase {
    func testInit() throws {
        let xs: SortedArray = [3, 1, 2, 4, 7]
        XCTAssertEqual(xs.sorted, [1, 2, 3, 4, 7])
        XCTAssertEqual(Array(xs), xs.sorted)
        XCTAssertEqual(xs.count, 5)
        XCTAssert(!xs.isEmpty)

        let ys = SortedArray<Int>()
        XCTAssertEqual(Array(ys), ys.sorted)
        XCTAssertEqual(ys.count, 0)
        XCTAssert(ys.isEmpty)

        let zs = SortedArray(uncheckedSortedElements: [3, 2, 7])
        XCTAssertEqual(zs.sorted, [3, 2, 7])
    }

    func testBinarySearch() {
        let xs: SortedArray = [1, 2, 2, 2, 3]
        for x in 0..<4 {
            XCTAssertEqual(xs.firstIndex(of: x), xs.sorted.firstIndex(of: x))
            XCTAssertEqual(xs.lastIndex(of: x), xs.sorted.lastIndex(of: x))
            XCTAssertEqual(xs.contains(x), xs.sorted.contains(x))
        }
    }

    func testDeletion() {
        var xs: SortedArray = [1, 2, 2, 2, 3]
        xs.remove(at: xs.firstIndex(of: 1)!)
        XCTAssertEqual(xs, [2, 2, 2, 3])
        xs.remove(2)
        XCTAssertEqual(xs, [3])

        xs.insert(1)
        xs.insert(1)
        xs.insert(2)
        XCTAssertEqual(xs, [1, 1, 2, 3])
    }
}
