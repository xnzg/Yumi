/// An unordered collection of identifiable elements.
///
/// This is a thin wrapper over `Dictionary`.
public struct IdentifiedSet<Value: Identifiable> {
    @usableFromInline
    var storage: [Value.ID: Value]

    @inlinable
    public init() {
        storage = [:]
    }

    @inlinable
    public init<S: Sequence>(_ xs: S) where S.Element == Value {
        storage = [:]
        for x in xs {
            storage[x.id] = x
        }
    }

    @inlinable
    public subscript(id: Value.ID) -> Value? {
        _read {
            yield storage[id]
        }
        _modify {
            yield &storage[id]
            if let value = storage[id] {
                precondition(id == value.id)
            }
        }
    }

    /// Inserts the specified value.
    ///
    /// If a value with the same ID already exists, that value will be replaced.
    @inlinable
    public mutating func insert(_ value: Value) {
        storage[value.id] = value
    }

    /// Returns the collection of all IDs present.
    @inlinable
    public var ids: Dictionary<Value.ID, Value>.Keys {
        storage.keys
    }
}

@available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
extension IdentifiedSet: Collection {
    public typealias Index = Dictionary<Value.ID, Value>.Values.Index

    @inlinable
    public var startIndex: Index {
        storage.values.startIndex
    }

    @inlinable
    public var endIndex: Index {
        storage.values.endIndex
    }

    @inlinable
    public func index(after i: Index) -> Index {
        storage.values.index(after: i)
    }

    @inlinable
    public subscript(position: Index) -> Value {
        storage.values[position]
    }

    @inlinable
    public var isEmpty: Bool {
        storage.isEmpty
    }

    @inlinable
    public var count: Int {
        storage.count
    }
}

@available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
extension IdentifiedSet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Value...) {
        self = .init(elements)
    }
}

@available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
extension IdentifiedSet: Equatable where Value: Equatable {}

@available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
extension IdentifiedSet: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for value in storage.values {
            try container.encode(value)
        }
    }
}

@available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
extension IdentifiedSet: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        storage = [:]
        while !container.isAtEnd {
            let value = try container.decode(Value.self)
            storage[value.id] = value
        }
    }
}

@available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
extension IdentifiedSet {
    /// Builds a new identified set by flat mapping every value.
    ///
    /// If multiple entries produce values of the same ID, it is undefined which one will survive.
    @inlinable
    public static func flatMapping<Source: Sequence, Transformed: Sequence>(
        _ source: Source,
        transform: (Source.Element) throws -> Transformed
    ) rethrows -> IdentifiedSet<Transformed.Element>
    where Transformed.Element: Identifiable
    {
        var output: IdentifiedSet<Transformed.Element> = []
        for element in source {
            for newValue in try transform(element) {
                output.insert(newValue)
            }
        }
        return output
    }

    @inlinable
    public static func mapping<Source: Sequence, NewValue: Identifiable>(
        _ source: Source,
        transform: (Source.Element) throws -> NewValue
    ) rethrows -> IdentifiedSet<NewValue>
    {
        try flatMapping(source) {
            try CollectionOfOne(transform($0))
        }
    }

    @inlinable
    public static func compactMapping<Source: Sequence, NewValue: Identifiable>(
        _ source: Source,
        transform: (Source.Element) throws -> NewValue?
    ) rethrows -> IdentifiedSet<NewValue>
    {
        var output: IdentifiedSet<NewValue> = []
        for element in source {
            if let value = try transform(element) {
                output.insert(value)
            }
        }
        return output
    }
}
