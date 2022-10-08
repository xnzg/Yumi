[![codecov](https://codecov.io/gh/xnzg/Yumi/branch/main/graph/badge.svg?token=COVD6RSE3R)](https://codecov.io/gh/xnzg/Yumi)

# Yumi
Some commonly used functionality.

Yumi stands for [corn](https://en.wikipedia.org/wiki/Maize) in [Pinyin](https://en.wikipedia.org/wiki/Pinyin). The name comes from the fact that corn is the most cultivated grain on the planet.

## Contents

The package currently does the following.

### Re-exports

Yumi re-exports some ”official” packages:

- `Algorithms` from [`swift-algorithms`](https://github.com/apple/swift-algorithms) by Apple.
- `Collections` from [`swift-collections`](https://github.com/apple/swift-collections) by Apple.

Also some more biased choices:
- `IdentifiedCollections` from [`swift-identified-collections`](https://github.com/pointfreeco/swift-identified-collections) by [Point-Free](https://www.pointfree.co).


### Collections

- `IdentifiedSet`.
- `SortedArray`.


# Utilities:

- `countEach(where:)` as a replacement for [SE-0220](https://github.com/apple/swift-evolution/blob/main/proposals/0220-count-where.md).
- Some equality helpers: `memoryEqual`, `@MemoryEqual` and `@AlwaysEqual`.
- `.sortedMerging(...)`, for merging two sorted sequences. There are two variants:
    - The first allows the caller to choose between keeping elements from both sequences or merging.
    - The second, more specialized one does merging in the fashion of a traditional merge sor
