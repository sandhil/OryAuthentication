// MARK: Set Membership

precedencegroup SetUnionPrecedence {
    associativity: left
    higherThan: ComparisonPrecedence
}

precedencegroup SetIntersectionPrecedence {
    associativity: left
    higherThan: ComparisonPrecedence
}

infix operator ∈ : ComparisonPrecedence
public func ∈ <T>(lhs: T, rhs: [T]) -> Bool where T : Equatable {
    return rhs.contains(lhs)
}

public func ∈ <T>(lhs: T, rhs: Set<T>) -> Bool {
    return rhs.contains(lhs)
}

extension ClosedRange where Bound : Comparable {
    public static func ∈ (lhs: Bound, rhs: ClosedRange) -> Bool {
        return rhs.contains(lhs)
    }
}

extension Range where Bound : Comparable {
    public static func ∈ (lhs: Bound, rhs: Range) -> Bool {
        return rhs.contains(lhs)
    }
}

// MARK: Set Non-Membership

infix operator ∉ : ComparisonPrecedence
public func ∉ <T>(lhs: T, rhs: [T]) -> Bool where T : Equatable {
    return ¬(lhs ∈ rhs)
}

public func ∉ <T>(lhs: T, rhs: Set<T>) -> Bool {
    return ¬(lhs ∈ rhs)
}

extension ClosedRange where Bound : Comparable {
    public static func ∉ (lhs: Bound, rhs: ClosedRange) -> Bool {
        return ¬(lhs ∈ rhs)
    }
}

extension Range where Bound : Comparable {
    public static func ∉ (lhs: Bound, rhs: Range) -> Bool {
        return ¬(lhs ∈ rhs)
    }
}

// MARK: Converse Set Membership

infix operator ∋ : ComparisonPrecedence
public func ∋ <T>(lhs: [T], rhs: T) -> Bool where T : Equatable {
    return rhs ∈ lhs
}

public func ∋ <T>(lhs: Set<T>, rhs: T) -> Bool {
    return rhs ∈ lhs
}

// MARK: Converse Set Non-Membership

infix operator ∌ : ComparisonPrecedence
public func ∌ <T>(lhs: [T], rhs: T) -> Bool where T : Equatable {
    return rhs ∉ lhs
}

public func ∌ <T>(lhs: Set<T>, rhs: T) -> Bool {
    return rhs ∉ lhs
}

// MARK: Set Intersection

infix operator ∩ : SetIntersectionPrecedence
public func ∩ <T>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    return lhs.intersection(rhs)
}

public func ∩ <T>(lhs: [T], rhs: [T]) -> [T] where T : Equatable {
    return lhs.intersection(rhs)
}

// MARK: Set Union

infix operator ∪ : SetUnionPrecedence
public func ∪ <T>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    return lhs.union(rhs)
}

public func ∪ <T>(lhs: [T], rhs: [T]) -> [T] where T : Equatable {
    return lhs.union(rhs)
}

// MARK: Subset

infix operator ⊆ : ComparisonPrecedence
public func ⊆ <T>(lhs: Set<T>, rhs: Set<T>) -> Bool {
    return lhs.isSubset(of: rhs)
}

public func ⊆ <T>(lhs: [T], rhs: [T]) -> Bool where T : Equatable {
    return lhs == rhs || (lhs ⊂ rhs)
}

// MARK: Proper Subset

infix operator ⊂ : ComparisonPrecedence
public func ⊂ <T>(lhs: Set<T>, rhs: Set<T>) -> Bool {
    return lhs.isStrictSubset(of: rhs)
}

public func ⊂ <T>(lhs: [T], rhs: [T]) -> Bool where T : Equatable {
    for value in lhs {
        if ¬(value ∈ rhs) {
            return false
        }
    }
    
    return true
}

// MARK: Not A Subset Of

infix operator ⊄ : ComparisonPrecedence
public func ⊄ <T>(lhs: Set<T>, rhs: Set<T>) -> Bool {
    return ¬(lhs ⊂ rhs)
}

public func ⊄ <T>(lhs: [T], rhs: [T]) -> Bool where T : Equatable {
    return ¬(lhs ⊂ rhs)
}

// MARK: Superset

infix operator ⊇ : ComparisonPrecedence
public func ⊇ <T>(lhs: Set<T>, rhs: Set<T>) -> Bool {
    return rhs ⊆ lhs
}

public func ⊇ <T>(lhs: [T], rhs: [T]) -> Bool where T : Equatable {
    return rhs ⊆ lhs
}

// MARK: Proper Superset

infix operator ⊃ : ComparisonPrecedence
public func ⊃ <T>(lhs: Set<T>, rhs: Set<T>) -> Bool {
    return rhs ⊂ lhs
}

public func ⊃ <T>(lhs: [T], rhs: [T]) -> Bool where T : Equatable {
    return rhs ⊂ lhs
}

// MARK: Not A Superset Of

infix operator ⊅ : ComparisonPrecedence
public func ⊅ <T>(lhs: Set<T>, rhs: Set<T>) -> Bool {
    return ¬(lhs ⊃ rhs)
}

public func ⊅ <T>(lhs: [T], rhs: [T]) -> Bool where T : Equatable {
    return ¬(lhs ⊃ rhs)
}
