//===----------------------------------------------------------------------===//
// MARK: sortedMerging()
//===----------------------------------------------------------------------===//

extension Sequence where Element: Comparable {
    /// Returns a new sequence that merges this sequence with the given sequence,
    /// ordered using `<`.
    ///
    /// - Complexity: `O(1)`
    ///
    /// - Parameters:
    ///   - other: The other sequence to be merged.
    ///
    /// - Returns: A sequence of elements from both sequences, ordered.
    @inlinable
    public func sortedMerging<Other: Sequence>(_ other: Other) -> some Sequence<Element>
    where Element == Other.Element
    {
        self.lazy.sortedMerging(other, by: <)
    }
}

extension Sequence {
    /// Returns a new array that merges this sequence with the given sequence
    /// in an ordered way, allowing merging duplicated elements in the process.
    ///
    /// This is an eager version of `sortedMerging` on `LazySequenceProtocol`.
    ///
    /// - Complexity: `O(n)`
    ///
    /// - Parameters:
    ///   - other: The other sequence to be merged.
    ///   - areInAscendingOrder: A predicate that returns `true` if the first
    ///   element should be placed before the second one.
    ///   - areDuplicates: A predicate that returns `true` if the two elements
    ///   are duplicates and should be merged into one. If `true`,
    ///   `mergeDuplicates` will be called.
    ///   - mergeDuplicates: A custom function to merge the two elements into
    ///   one.
    ///
    /// - Returns: An array of elements from both sequences, ordered.
    @inlinable
    public func sortedMerging<Other: Sequence>(
        _ other: Other,
        by areInAscendingOrder: (Element, Element) throws -> Bool,
        areDuplicates: (Element, Element) throws -> Bool = { _, _ in false },
        mergeDuplicates: (Element, Element) throws -> Element = { _, _ in fatalError("One must specify how to merge duplicates!") }
    ) rethrows -> [Element] where Element == Other.Element
    {
        var state = SortedMergingSequenceState(lhs: self, rhs: other)
        var list: [Element] = []

        while true {
            let next = try state.step(
                areInAscendingOrder: areInAscendingOrder,
                areDuplicates: areDuplicates,
                mergeDuplicates: mergeDuplicates)
            guard let next else { break }
            list.append(next)
        }
        return list
    }
}

//===----------------------------------------------------------------------===//
// MARK: lazy.sortedMerging()
//===----------------------------------------------------------------------===//

extension LazySequenceProtocol {
    /// Returns a new sequence that merges this sequence with the given sequence
    /// in an ordered way, allowing merging duplicated elements in the process.
    ///
    /// The two sequences, `self` and `other`, should be sorted with respect
    /// to `areInAscendingOrder` for the result to be meaningful.
    ///
    /// You can use this method to either do a plain merging, like a
    /// (merge sort)[https://en.wikipedia.org/wiki/Merge_sort], and keep all
    /// elements from both sequences. Alternatively, you can merge two elements,
    /// one from each sequence, into one element, like the example below:
    ///
    /// ```swift
    /// let julSales = [("Alex", 10), ("Bob", 20)]
    /// let augSales = [("Bob", 20), ("Carl", 30)]
    ///
    /// let totalSales = julSales.sortedMerging(augSales) { $0.0 < $0.1 }
    ///   areDuplicates: { $0.0 == $1.0 }
    ///   mergeDuplicates: { ($0.0, $0.1 + $1.1) }
    /// ```
    ///
    /// - Complexity: `O(1)`
    ///
    /// - Parameters:
    ///   - other: The other sequence to be merged.
    ///   - areInAscendingOrder: A predicate that returns `true` if the first
    ///   element should be placed before the second one.
    ///   - areDuplicates: A predicate that returns `true` if the two elements
    ///   are duplicates and should be merged into one. If `true`,
    ///   `mergeDuplicates` will be called.
    ///   - mergeDuplicates: A custom function to merge the two elements into
    ///   one.
    ///
    /// - Returns: A sequence of elements from both sequences, ordered.
    @inlinable
    public func sortedMerging<Other: Sequence>(
        _ other: Other,
        by areInAscendingOrder: @escaping (Element, Element) -> Bool,
        areDuplicates: @escaping (Element, Element) -> Bool = { _, _ in false },
        mergeDuplicates: @escaping (Element, Element) -> Element = { _, _ in fatalError("One must specify how to merge duplicates!") }
    ) -> some Sequence<Element>
    where Element == Other.Element
    {
        SortedMergeSequence(
            lhs: self,
            rhs: other,
            areInAscendingOrder: areInAscendingOrder,
            areDuplicates: areDuplicates,
            mergeDuplicates: mergeDuplicates)
    }
}

//===----------------------------------------------------------------------===//
// MARK: Implementation Details
//===----------------------------------------------------------------------===//

/// A sequence wrapper that merges two sequences in order, optionally removing duplicates.
@usableFromInline
struct SortedMergeSequence<LHS: Sequence, RHS: Sequence> where LHS.Element == RHS.Element {
    @usableFromInline
    typealias Element = LHS.Element

    @usableFromInline
    var lhs: LHS
    @usableFromInline
    var rhs: RHS
    @usableFromInline
    var areInAscendingOrder: (Element, Element) -> Bool
    @usableFromInline
    var areDuplicates: (Element, Element) -> Bool
    @usableFromInline
    var mergeDuplicates: (Element, Element) -> Element

    @inlinable
    init(
        lhs: LHS,
        rhs: RHS,
        areInAscendingOrder: @escaping (Element, Element) -> Bool,
        areDuplicates: @escaping (Element, Element) -> Bool,
        mergeDuplicates: @escaping (Element, Element) -> Element
    ) {
        self.lhs = lhs
        self.rhs = rhs
        self.areInAscendingOrder = areInAscendingOrder
        self.areDuplicates = areDuplicates
        self.mergeDuplicates = mergeDuplicates
    }

    @inlinable
    func makeIterator() -> Iterator {
        .init(
            lhs: lhs,
            rhs: rhs,
            areInAscendingOrder: areInAscendingOrder,
            areDuplicates: areDuplicates,
            mergeDuplicates: mergeDuplicates)
    }
}

@usableFromInline
struct SortedMergingSequenceState<LHS: Sequence, RHS: Sequence> where LHS.Element == RHS.Element {
    @usableFromInline
    var lhsIter: LHS.Iterator
    @usableFromInline
    var rhsIter: RHS.Iterator
    @usableFromInline
    var lhs: LHS.Element?
    @usableFromInline
    var rhs: LHS.Element?

    @inlinable
    init(lhs: LHS, rhs: RHS) {
        lhsIter = lhs.makeIterator()
        rhsIter = rhs.makeIterator()
        self.lhs = lhsIter.next()
        self.rhs = rhsIter.next()
    }

    @usableFromInline
    typealias Element = LHS.Element

    @inlinable
    mutating func step(
        areInAscendingOrder: (Element, Element) throws -> Bool,
        areDuplicates: (Element, Element) throws -> Bool,
        mergeDuplicates: (Element, Element) throws -> Element
    ) rethrows -> Element?
    {
        switch (lhs, rhs) {
        case (nil, nil):
            return nil
        case let (.some(x), nil):
            lhs = lhsIter.next()
            return x
        case let (nil, .some(y)):
            rhs = rhsIter.next()
            return y
        case let (.some(x), .some(y)):
            guard try !areDuplicates(x, y) else {
                let z = try mergeDuplicates(x, y)
                lhs = lhsIter.next()
                rhs = rhsIter.next()
                return z
            }

            if try areInAscendingOrder(x, y) {
                lhs = lhsIter.next()
                return x
            } else {
                rhs = rhsIter.next()
                return y
            }
        }
    }
}

extension SortedMergeSequence: Sequence {
    /// The iterator for a ``SortedMergeSequence``.`
    @usableFromInline
    struct Iterator: IteratorProtocol {
        @usableFromInline
        typealias Element = LHS.Element

        @usableFromInline
        var state: SortedMergingSequenceState<LHS, RHS>
        @usableFromInline
        var areInAscendingOrder: (Element, Element) -> Bool
        @usableFromInline
        var areDuplicates: (Element, Element) -> Bool
        @usableFromInline
        var mergeDuplicates: (Element, Element) -> Element

        @inlinable
        init(
            lhs: LHS,
            rhs: RHS,
            areInAscendingOrder: @escaping (Element, Element) -> Bool,
            areDuplicates: @escaping (Element, Element) -> Bool,
            mergeDuplicates: @escaping (Element, Element) -> Element
        ) {
            self.state = .init(lhs: lhs, rhs: rhs)
            self.areInAscendingOrder = areInAscendingOrder
            self.areDuplicates = areDuplicates
            self.mergeDuplicates = mergeDuplicates
        }

        @inlinable
        mutating func next() -> Element? {
            state.step(
                areInAscendingOrder: areInAscendingOrder,
                areDuplicates: areDuplicates,
                mergeDuplicates: mergeDuplicates)
        }
    }
}

extension SortedMergeSequence: LazySequenceProtocol where LHS: LazySequenceProtocol {}
