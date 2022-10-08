/// An array that keeps its elements sorted. One can use `partitionIndex(where:)` to do fast binary search.
public struct SortedArray<Element: Comparable>: Equatable {
    @usableFromInline var storage: [Element]

    /// Consturcts a sorted array from the given sequence.
    @inlinable
    public init<S: Sequence>(_ xs: S) where S.Element == Element {
        storage = Array(xs)
        storage.sort()
    }

    @inlinable
    public init() {
        storage = []
    }

    @_disfavoredOverload
    @inlinable
    public init<S: Sequence>(uncheckedSortedElements xs: S) where S.Element == Element {
        storage = Array(xs)
    }

    /// Returns a copy to the underlying array.
    @inlinable
    public var sorted: [Element] {
        storage
    }

    public func merging(_ other: Self) -> Self {
        .init(uncheckedSortedElements: sortedMerging(with: other))
    }
}

extension SortedArray: ExpressibleByArrayLiteral {
    @inlinable
    public init(arrayLiteral elements: Element...) {
        self = Self(elements)
    }
}

extension SortedArray: RandomAccessCollection {
    public typealias Index = Int

    /// Returns the start index.
    @inlinable
    public var startIndex: Int {
        storage.startIndex
    }

    /// Returns the end index.
    @inlinable
    public var endIndex: Int {
        storage.endIndex
    }

    /// Next index.
    @inlinable
    public func index(after i: Int) -> Int {
        i + 1
    }

    /// Previous index.
    @inlinable
    public func index(before i: Int) -> Int {
        i - 1
    }

    /// Index from offset.
    @inlinable
    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        storage.index(i, offsetBy: distance)
    }

    /// Index from offset if within the index limit.
    @inlinable
    public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        storage.index(i, offsetBy: distance, limitedBy: limit)
    }

    /// Gets the value at the current index.
    @inlinable
    public subscript(position: Int) -> Element {
        _read {
            yield storage[position]
        }
    }

    /// Total count of elements.
    @inlinable
    public var count: Int {
        storage.count
    }

    /// True if collection is empty.
    @inlinable
    public var isEmpty: Bool {
        storage.isEmpty
    }
}

extension SortedArray {
    /// Returns the index of the first occurrence of the supplied element.
    ///
    /// - Complexity: `O(log n)`
    @inlinable
    public func firstIndex(of element: Element) -> Int? {
        let i = partitioningIndex { $0 >= element }
        guard i < endIndex else { return nil }
        guard self[i] == element else { return nil }
        return i
    }

    /// Returns the index of the last occurrence of the supplied element.
    ///
    /// - Complexity: `O(log n)`
    @inlinable
    public func lastIndex(of element: Element) -> Int? {
        var i = partitioningIndex { $0 > element }
        guard i > 0 else { return nil }
        i -= 1
        guard self[i] == element else { return nil }
        return i
    }

    /// Checks if the given element exists in the collection.
    ///
    /// - Complexity: `O(log n)`
    @inlinable
    public func contains(_ target: Element) -> Bool {
        firstIndex(of: target) != nil
    }

    /// Inserts a new element. The resulting array is still sorted.
    @inlinable
    public mutating func insert(_ target: Element) {
        let i = storage.partitioningIndex { $0 > target }
        storage.insert(target, at: i)
    }

    /// Removes the value at the given index.
    @inlinable
    public mutating func remove(at index: Int) {
        storage.remove(at: index)
    }

    @inlinable
    public mutating func remove(_ target: Element) {
        guard let i = firstIndex(of: target),
              let j = lastIndex(of: target)
        else { return }
        storage.removeSubrange(i...j)
    }
}
