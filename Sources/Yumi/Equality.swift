/// Compares two values by their raw bytes.
@inlinable
public func memoryEqual<Value>(_ lhs: Value, _ rhs: Value) -> Bool {
    withUnsafePointer(to: lhs) { px in
        withUnsafePointer(to: rhs) { py in
            let count = MemoryLayout<Value>.size
            let pbx = UnsafeRawBufferPointer(start: UnsafeRawPointer(px), count: count)
            let pby = UnsafeRawBufferPointer(start: UnsafeRawPointer(py), count: count)
            for i in 0..<count {
                guard pbx[i] == pby[i] else { return false }
            }
            return true
        }
    }
}

/// A property wrapper that defines `Equatable` in terms of the raw bytes of the wrapped value.
///
/// This provides a "weak" equality relation. In Swift, if two values have the same raw bytes,
/// they must equal. But the reverse is not true: two values can have different raw bytes while
/// still being equal to each other.
///
/// Among other things, SwiftUI uses a similar trick to perform view-diff, unless you explictly
/// modify some view with `equatable()`.
@propertyWrapper
public struct MemoryEqual<Value>: Equatable {
    public var wrappedValue: Value

    @inlinable
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        memoryEqual(lhs.wrappedValue, rhs.wrappedValue)
    }

    @inlinable
    public var projectedValue: MemoryEqual<Value> {
        get { self }
        set { self = newValue }
    }
}

/// A property wrapper that returns true for `==`.
///
/// This is useful to skip equality check for certain properties in a struct.
/// For instance, if your struct maintains a private cache that is determined
/// by other properties in the struct, you can make it as `@AlwaysEqual`.
@propertyWrapper
public struct AlwaysEqual<Value>: Equatable {
    public var wrappedValue: Value

    @inlinable
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }

    @inlinable
    public var projectedValue: AlwaysEqual<Value> {
        get { self }
        set { self = newValue }
    }
}
