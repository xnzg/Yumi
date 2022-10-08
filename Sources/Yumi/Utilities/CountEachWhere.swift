public extension Sequence {
    /// Counts the number of elements satisfying the given predicate.
    ///
    /// - Note: This was proposed in SE-0220 but reverted due to affecting type checker performance.
    /// See discussion [here](https://forums.swift.org/t/require-parameter-names-when-referencing-to-functions/27048).
    @inlinable
    func countEach(where isIncluded: (Element) -> Bool) -> Int {
        var sum = 0
        for x in self {
            if isIncluded(x) {
                sum += 1
            }
        }
        return sum
    }
}
