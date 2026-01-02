import Foundation

/// A thread-safe wrapper around Swift's `Set` type.
///
/// `ThreadSafeSet` provides synchronized access to an underlying set using
/// a configurable locking strategy. All operations are atomic and thread-safe.
///
/// **Example:**
/// ```swift
/// let userIds = ThreadSafeSet<String>()
/// userIds.insert("user123")
/// print(userIds.contains("user123")) // true
/// ```
///
/// **Set Operations:**
/// ```swift
/// let set1: ThreadSafeSet<Int> = [1, 2, 3]
/// let set2: ThreadSafeSet<Int> = [3, 4, 5]
/// let union = set1.union(set2)  // [1, 2, 3, 4, 5]
/// ```
public final class ThreadSafeSet<Element: Hashable>: ThreadSafeCollection, @unchecked Sendable {
  private var storage: Set<Element>
  private let lock: LockingStrategy

  // MARK: - Initialization

  /// Creates an empty thread-safe set with the specified locking strategy.
  ///
  /// - Parameter lock: The locking strategy to use. Defaults to `ReadWriteLock`.
  public init(lock: LockingStrategy = ReadWriteLock()) {
    self.storage = []
    self.lock = lock
  }

  /// Creates a thread-safe set from an existing set.
  ///
  /// - Parameters:
  ///   - set: The initial elements.
  ///   - lock: The locking strategy to use. Defaults to `ReadWriteLock`.
  public init(_ set: Set<Element>, lock: LockingStrategy = ReadWriteLock()) {
    self.storage = set
    self.lock = lock
  }

  // MARK: - ThreadSafeCollection

  public var count: Int {
    lock.read { storage.count }
  }

  public var isEmpty: Bool {
    lock.read { storage.isEmpty }
  }

  public func removeAll() {
    lock.write { storage.removeAll() }
  }

  // MARK: - Set Operations

  /// Inserts the given element in the set if it is not already present.
  ///
  /// - Parameter newMember: An element to insert into the set.
  /// - Returns: A tuple containing a Boolean value indicating whether the insertion
  ///   occurred and the member after the operation.
  @discardableResult
  public func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
    lock.write {
      storage.insert(newMember)
    }
  }

  /// Returns a Boolean value indicating whether the set contains the given element.
  ///
  /// - Parameter member: An element to look for in the set.
  /// - Returns: `true` if the element exists in the set; otherwise, `false`.
  public func contains(_ member: Element) -> Bool {
    lock.read {
      storage.contains(member)
    }
  }

  /// Removes the given element from the set.
  ///
  /// - Parameter member: The element to remove.
  /// - Returns: The element that was removed, or `nil` if the element was not present.
  @discardableResult
  public func remove(_ member: Element) -> Element? {
    lock.write {
      storage.remove(member)
    }
  }

  // MARK: - Set Algebra Operations

  /// Returns a new set with the elements of both this set and the given set.
  ///
  /// - Parameter other: Another set.
  /// - Returns: A new set with the combined elements.
  public func union(_ other: ThreadSafeSet<Element>) -> Set<Element> {
    lock.read {
      other.lock.read {
        storage.union(other.storage)
      }
    }
  }

  /// Returns a new set with the elements that are common to both this set and the given set.
  ///
  /// - Parameter other: Another set.
  /// - Returns: A new set with the common elements.
  public func intersection(_ other: ThreadSafeSet<Element>) -> Set<Element> {
    lock.read {
      other.lock.read {
        storage.intersection(other.storage)
      }
    }
  }

  /// Returns a new set containing the elements of this set that do not occur in the given set.
  ///
  /// - Parameter other: Another set.
  /// - Returns: A new set with the difference.
  public func subtracting(_ other: ThreadSafeSet<Element>) -> Set<Element> {
    lock.read {
      other.lock.read {
        storage.subtracting(other.storage)
      }
    }
  }

  /// Returns a new set with the elements that are either in this set or in the given set, but not in both.
  ///
  /// - Parameter other: Another set.
  /// - Returns: A new set with the symmetric difference.
  public func symmetricDifference(_ other: ThreadSafeSet<Element>) -> Set<Element> {
    lock.read {
      other.lock.read {
        storage.symmetricDifference(other.storage)
      }
    }
  }

  /// Returns a Boolean value indicating whether this set is a subset of the given set.
  ///
  /// - Parameter other: Another set.
  /// - Returns: `true` if this set is a subset; otherwise, `false`.
  public func isSubset(of other: ThreadSafeSet<Element>) -> Bool {
    lock.read {
      other.lock.read {
        storage.isSubset(of: other.storage)
      }
    }
  }

  /// Returns a Boolean value indicating whether this set is a superset of the given set.
  ///
  /// - Parameter other: Another set.
  /// - Returns: `true` if this set is a superset; otherwise, `false`.
  public func isSuperset(of other: ThreadSafeSet<Element>) -> Bool {
    lock.read {
      other.lock.read {
        storage.isSuperset(of: other.storage)
      }
    }
  }

  /// Returns a Boolean value indicating whether this set has no members in common with the given set.
  ///
  /// - Parameter other: Another set.
  /// - Returns: `true` if the sets are disjoint; otherwise, `false`.
  public func isDisjoint(with other: ThreadSafeSet<Element>) -> Bool {
    lock.read {
      other.lock.read {
        storage.isDisjoint(with: other.storage)
      }
    }
  }

  // MARK: - Functional Operations

  /// Returns a consistent snapshot of all elements in the set.
  ///
  /// This operation is atomic and returns a copy of the current state.
  ///
  /// - Returns: A set containing all elements.
  public func snapshot() -> Set<Element> {
    lock.read { storage }
  }

  /// Executes a closure on each element in the set.
  ///
  /// The iteration is performed on a consistent snapshot of the set.
  ///
  /// - Parameter body: A closure that takes an element as a parameter.
  /// - Throws: Rethrows any error thrown by the body closure.
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try lock.read {
      try storage.forEach(body)
    }
  }

  /// Returns an array containing the results of mapping the given closure over the set's elements.
  ///
  /// - Parameter transform: A mapping closure.
  /// - Returns: An array of transformed elements.
  /// - Throws: Rethrows any error thrown by the transform closure.
  public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
    try lock.read {
      try storage.map(transform)
    }
  }

  /// Returns a set containing the elements that satisfy the given predicate.
  ///
  /// - Parameter isIncluded: A closure that takes an element and returns a Boolean value.
  /// - Returns: A set of elements that satisfy the predicate.
  /// - Throws: Rethrows any error thrown by the isIncluded closure.
  public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Set<Element> {
    try lock.read {
      try storage.filter(isIncluded)
    }
  }
}

// MARK: - ExpressibleByArrayLiteral

extension ThreadSafeSet: ExpressibleByArrayLiteral {
  public convenience init(arrayLiteral elements: Element...) {
    self.init(Set(elements))
  }
}

// MARK: - CustomStringConvertible

extension ThreadSafeSet: CustomStringConvertible {
  public var description: String {
    lock.read { storage.description }
  }
}
