import XCTest
import Yumi

final class SortedMergeSequenceTests: XCTestCase {
    func testSparse() {
        for _ in 0..<10 {
            var lhs: [Int] = []
            var rhs: [Int] = []
            for _ in 0..<100 {
                lhs.append((0..<10000).randomElement()!)
            }
            for _ in 0..<100 {
                rhs.append((0..<10000).randomElement()!)
            }
            lhs.sort()
            rhs.sort()
            var expected = lhs + rhs
            expected.sort()
            let actual = Array(lhs.sortedMerging(rhs))
            XCTAssertEqual(expected, actual)
        }
    }

    func testDense() {
        for _ in 0..<10 {
            var lhs: [Int] = []
            var rhs: [Int] = []
            for _ in 0..<100 {
                lhs.append((0..<30).randomElement()!)
            }
            for _ in 0..<100 {
                rhs.append((0..<30).randomElement()!)
            }
            lhs.sort()
            rhs.sort()
            var expected = lhs + rhs
            expected.sort()
            let actual = Array(lhs.sortedMerging(rhs))
            XCTAssertEqual(expected, actual)
        }
    }

    func testDict() {
        let lhs: [(String, Int)] = [
            ("Alice", 3),
            ("Bob", 2)
        ]
        let rhs: [(String, Int)] = [
            ("Bob", 3),
            ("Cersei", 4)
        ]

        let merged = lhs.sortedMerging(rhs) {
            $0.0 < $1.0
        } areDuplicates: {
            $0.0 == $1.0
        } mergeDuplicates: {
            ($0.0, $0.1 + $1.1)
        }

        XCTAssertEqual(merged.map(\.0), ["Alice", "Bob", "Cersei"])
        XCTAssertEqual(merged.map(\.1), [3, 5, 4])

        var lazyMerged: [(String, Int)] = []
        lhs.lazy.sortedMerging(rhs) {
            $0.0 < $1.0
        } areDuplicates: {
            $0.0 == $1.0
        } mergeDuplicates: {
            ($0.0, $0.1 + $1.1)
        }
        .forEach {
            lazyMerged.append($0)
        }

        XCTAssertEqual(lazyMerged.map(\.0), ["Alice", "Bob", "Cersei"])
        XCTAssertEqual(lazyMerged.map(\.1), [3, 5, 4])
    }
}
