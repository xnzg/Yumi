# Sorted Merge

Merging two *sorted* sequences.

## Overview

The method `sortedMerging` can merge two sorted sequences:

```swift
for x in [1, 3, 5].sortedMerging([2, 3, 4]) {
    print(x)
}

// Prints 1
// Prints 2
// Prints 3
// Prints 3
// Prints 4
// Prints 5
```

With dictionary-like sequences, it can also merge entries with the same key:

```swift
let julSales = [("Alex", 10), ("Bob", 20)]
let augSales = [("Bob", 20), ("Carl", 30)]

let totalSales = julSales.sortedMerging(augSales) { $0.0 < $0.1 }
  areDuplicates: { $0.0 == $1.0 }
  mergeDuplicates: { ($0.0, $0.1 + $1.1) }

for (person, sale) in totalSales {
    print(person, sale)
}

// Prints "Alex" 10
// Prints "Bob" 40
// Prints "Carl" 30
```

### Parameters

Other than the two sequences, `sortedMerging` methods take three parameters:

- `areInAscendingOrder`, which serves as `<` in a `Comparable` implementation.
- `areDuplicates`, which serves as `==` in an `Equatable` implementation. If you do not want to merge any pair of elements, simply return `false`. This is also the default implementation when no value is provided.
- `mergeDuplicates`, which merges elements identified as duplicates by `areDuplicates`.

> Important: The two input sequences must be sorted with respect to the provided `areInAscendingOrder` for the result to be meaningful.

### Variants

There are an eager version and a lazy version. The former takes non-escaping throwing closures, whereas the latter takes escaping non-throwing ones. You might be forced to use one of the two, given these constraints. If not, you can use `.lazy` to use the lazy version.

If your sequence’s element type conforms to `Comparable`, there is also a shortcut version that does not merge duplicates. It orders elements by `<`, and returns a sequence that produces elements lazily.
