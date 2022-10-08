public struct SortedMergeSequence<LHS: Sequence, RHS: Sequence>: Sequence where LHS.Element == RHS.Element {
    public typealias Element = LHS.Element

    /// Instructs the sequence what to do for next.
    public enum Step {
        /// Returns the value from the first sequence and moves the corresponding iterator.
        case first
        /// Returns the value from the second sequence and moves the corresponding iterator.
        case second
        /// Returns the supplied value and moves both iterators.
        case both(Element)
    }

    @usableFromInline
    var lhs: LHS
    @usableFromInline
    var rhs: RHS
    @usableFromInline
    var merge: (Element, Element) -> Step

    @inlinable
    init(lhs: LHS, rhs: RHS, merge: @escaping (Element, Element) -> Step) {
        self.lhs = lhs
        self.rhs = rhs
        self.merge = merge
    }

    public func makeIterator() -> Iterator {
        .init(lhsSeq: lhs, rhsSeq: rhs, merge: merge)
    }

    public struct Iterator: IteratorProtocol {
        public typealias Element = LHS.Element

        @usableFromInline
        var lhsIter: LHS.Iterator
        @usableFromInline
        var rhsIter: RHS.Iterator
        @usableFromInline
        var lhs: LHS.Element?
        @usableFromInline
        var rhs: LHS.Element?
        @usableFromInline
        var merge: (Element, Element) -> Step

        @inlinable
        init(lhsSeq: LHS, rhsSeq: RHS, merge: @escaping (Element, Element) -> Step) {
            lhsIter = lhsSeq.makeIterator()
            rhsIter = rhsSeq.makeIterator()
            lhs = lhsIter.next()
            rhs = rhsIter.next()
            self.merge = merge
        }

        @inlinable
        public mutating func next() -> Element? {
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
                switch merge(x, y) {
                case .first:
                    lhs = lhsIter.next()
                    return x
                case .second:
                    rhs = rhsIter.next()
                    return y
                case .both(let z):
                    lhs = lhsIter.next()
                    rhs = rhsIter.next()
                    return z
                }
            }
        }
    }
}

extension Sequence {
    /// Merges two sorted sequences using the provided comparator,
    /// but allows merging a pair of element (e.g. with the same key) into one.
    @inlinable
    public func sortedMerging<Other: Sequence>(
        with other: Other,
        merge: @escaping (Element, Element) -> SortedMergeSequence<Self, Other>.Step)
    -> SortedMergeSequence<Self, Other>
    where Element == Other.Element
    {
        .init(lhs: self, rhs: other, merge: merge)
    }

    /// Merges two sorted sequences using the provided comparator.
    @inlinable
    public func sortedMerging<Other: Sequence>(
        with other: Other,
        by isInAscendingOrder: @escaping (Element, Element) -> Bool)
    -> SortedMergeSequence<Self, Other>
    where Element == Other.Element
    {
        .init(lhs: self, rhs: other) { x, y in
            isInAscendingOrder(x, y) ? .first : .second
        }
    }
}

extension Sequence where Element: Comparable {
    /// Merges two sorted sequences.
    @inlinable
    public func sortedMerging<Other: Sequence>(with other: Other)
    -> SortedMergeSequence<Self, Other>
    where Element == Other.Element
    {
        sortedMerging(with: other, by: <)
    }
}
