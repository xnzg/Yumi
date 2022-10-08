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
            let actual = Array(lhs.sortedMerging(with: rhs))
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
            let actual = Array(lhs.sortedMerging(with: rhs))
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
        var merged: [(String, Int)] = []

        lhs.sortedMerging(with: rhs) {
            guard $0.0 == $1.0 else {
                return $0.0 < $1.0 ? .first : .second

            }
            return .both(($0.0, $0.1 + $1.1))
        }.forEach {
            merged.append($0)
        }

        XCTAssertEqual(merged.map(\.0), ["Alice", "Bob", "Cersei"])
        XCTAssertEqual(merged.map(\.1), [3, 5, 4])
    }
}
