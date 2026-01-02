import Foundation

/// A thread-safe wrapper around Swift's `Array` type.
///
/// `ThreadSafeArray` provides synchronized access to an underlying array using
/// a configurable locking strategy. All operations are atomic and thread-safe.
///
/// **Example:**
/// ```swift
/// let array = ThreadSafeArray<Int>()
/// array.append(1)
/// array.append(2)
/// print(array.count) // 2
/// ```
///
/// **Concurrency:**
/// ```swift
/// let array = ThreadSafeArray<String>()
/// await withTaskGroup(of: Void.self) { group in
///     for i in 0..<100 {
///         group.addTask {
///             array.append("Item \(i)")
///         }
///     }
/// }
/// ```
public final class ThreadSafeArray<Element>: ThreadSafeSequence, ThreadSafeSubscriptable,
  @unchecked Sendable
{
  private var storage: Array<Element>
  private let lock: LockingStrategy

  // MARK: - Initialization

  /// Creates an empty thread-safe array with the specified locking strategy.
  ///
  /// - Parameter lock: The locking strategy to use. Defaults to `ReadWriteLock`.
  public init(lock: LockingStrategy = ReadWriteLock()) {
    self.storage = []
    self.lock = lock
  }

  /// Creates a thread-safe array from an existing array.
  ///
  /// - Parameters:
  ///   - elements: The initial elements.
  ///   - lock: The locking strategy to use. Defaults to `ReadWriteLock`.
  public init(_ elements: [Element], lock: LockingStrategy = ReadWriteLock()) {
    self.storage = elements
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

  // MARK: - ThreadSafeSequence

  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try lock.read {
      try storage.forEach(body)
    }
  }

  public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
    try lock.read {
      try storage.map(transform)
    }
  }

  public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
    try lock.read {
      try storage.filter(isIncluded)
    }
  }

  public func snapshot() -> [Element] {
    lock.read { storage }
  }

  // MARK: - ThreadSafeSubscriptable

  public subscript(index: Int) -> Element? {
    get {
      lock.read {
        guard index >= 0 && index < storage.count else { return nil }
        return storage[index]
      }
    }
    set {
      lock.write {
        guard index >= 0 && index < storage.count else { return }
        if let newValue = newValue {
          storage[index] = newValue
        }
      }
    }
  }

  // MARK: - Array-Specific Operations

  /// Adds an element to the end of the array.
  ///
  /// - Parameter element: The element to append.
  public func append(_ element: Element) {
    lock.write {
      storage.append(element)
    }
  }

  /// Inserts an element at the specified position.
  ///
  /// - Parameters:
  ///   - element: The element to insert.
  ///   - index: The position at which to insert the element.
  public func insert(_ element: Element, at index: Int) {
    lock.write {
      guard index >= 0 && index <= storage.count else { return }
      storage.insert(element, at: index)
    }
  }

  /// Removes and returns the element at the specified position.
  ///
  /// - Parameter index: The position of the element to remove.
  /// - Returns: The removed element, or `nil` if the index is out of bounds.
  @discardableResult
  public func remove(at index: Int) -> Element? {
    lock.write {
      guard index >= 0 && index < storage.count else { return nil }
      return storage.remove(at: index)
    }
  }

  /// The first element of the array, or `nil` if the array is empty.
  public var first: Element? {
    lock.read { storage.first }
  }

  /// The last element of the array, or `nil` if the array is empty.
  public var last: Element? {
    lock.read { storage.last }
  }

  /// Returns a Boolean value indicating whether the array contains the given element.
  ///
  /// - Parameter element: The element to search for.
  /// - Returns: `true` if the element is found; otherwise, `false`.
  public func contains(_ element: Element) -> Bool where Element: Equatable {
    lock.read { storage.contains(element) }
  }
}

// MARK: - ExpressibleByArrayLiteral

extension ThreadSafeArray: ExpressibleByArrayLiteral {
  public convenience init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension ThreadSafeArray: CustomStringConvertible {
  public var description: String {
    lock.read { storage.description }
  }
}
