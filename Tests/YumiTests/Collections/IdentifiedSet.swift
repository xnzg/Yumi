import XCTest
import Yumi

final class IdentifiedSetTests: XCTestCase {
    struct Value: Identifiable, Equatable, Codable {
        var id: Int
        var score: Int
    }

    func testBasic() {
        var xs: IdentifiedSet<Value> = []
        xs.insert(.init(id: 1, score: 2))
        XCTAssertEqual(xs, [.init(id: 1, score: 2)])
        xs.insert(.init(id: 2, score: 3))
        XCTAssertEqual(xs, [.init(id: 1, score: 2), .init(id: 2, score: 3)])
        xs.insert(.init(id: 1, score: 4))
        XCTAssertEqual(xs, [.init(id: 1, score: 4), .init(id: 2, score: 3)])
        xs[2]?.score = 5
        XCTAssertEqual(xs, [.init(id: 1, score: 4), .init(id: 2, score: 5)])
        XCTAssertNil(xs[3])
        xs[3]?.score = 6
        XCTAssertEqual(xs, [.init(id: 1, score: 4), .init(id: 2, score: 5)])

        XCTAssertEqual(
            Array(xs).sorted { $0.id < $1.id },
            [.init(id: 1, score: 4), .init(id: 2, score: 5)])

        xs[1] = nil
        xs[2] = nil
        XCTAssert(xs.isEmpty)
    }

    func testCodable() throws {
        var xs: [Value] = []
        for _ in 0..<100 {
            xs.append(Value(id: (0..<90).randomElement()!, score: (0..<2).randomElement()!))
        }

        let direct = IdentifiedSet(xs)
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(xs)
        let decoder = JSONDecoder()
        let indirect = try decoder.decode(IdentifiedSet<Value>.self, from: encoded)

        XCTAssertEqual(direct, indirect)

        let doubleEncoded = try encoder.encode(indirect)
        let doubleIndirect = try decoder.decode(IdentifiedSet<Value>.self, from: doubleEncoded)

        XCTAssertEqual(direct, doubleIndirect)
    }

    func testMapAndFlatMap() {
        let xs = [1, 2]

        let result1: IdentifiedSet<Value> = .mapping(xs) {
            Value(id: $0, score: $0 * $0)
        }
        XCTAssertEqual(result1, [
            .init(id: 1, score: 1),
            .init(id: 2, score: 4)
        ])

        let result2: IdentifiedSet<Value> = .flatMapping(xs) {
            [
                Value(id: $0 * $0, score: $0),
                Value(id: -$0 * $0, score: $0)
            ]
        }
        XCTAssertEqual(result2, [
            .init(id: 1, score: 1),
            .init(id: -1, score: 1),
            .init(id: 4, score: 2),
            .init(id: -4, score: 2)
        ])

        let result3: IdentifiedSet<Value> = .compactMapping(xs) {
            let value = Value(id: $0, score: $0 * $0)
            return value.id == value.score ? nil : value
        }
        XCTAssertEqual(result3, [
            .init(id: 2, score: 4)
        ])
    }
}
