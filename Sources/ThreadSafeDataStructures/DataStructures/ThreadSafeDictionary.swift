import Foundation

/// A thread-safe wrapper around Swift's `Dictionary` type.
///
/// `ThreadSafeDictionary` provides synchronized access to an underlying dictionary using
/// a configurable locking strategy. All operations are atomic and thread-safe.
///
/// **Example:**
/// ```swift
/// let cache = ThreadSafeDictionary<String, Int>()
/// cache["userId"] = 42
/// print(cache["userId"]) // Optional(42)
/// ```
///
/// **Concurrency:**
/// ```swift
/// let cache = ThreadSafeDictionary<String, Data>()
/// await withTaskGroup(of: Void.self) { group in
///     for i in 0..<100 {
///         group.addTask {
///             cache["key\(i)"] = Data()
///         }
///     }
/// }
/// ```
public final class ThreadSafeDictionary<Key: Hashable, Value>: ThreadSafeCollection,
  ThreadSafeSubscriptable, @unchecked Sendable
{
  public typealias Element = (key: Key, value: Value)
  public typealias Index = Key

  private var storage: [Key: Value]
  private let lock: LockingStrategy

  // MARK: - Initialization

  /// Creates an empty thread-safe dictionary with the specified locking strategy.
  ///
  /// - Parameter lock: The locking strategy to use. Defaults to `ReadWriteLock`.
  public init(lock: LockingStrategy = ReadWriteLock()) {
    self.storage = [:]
    self.lock = lock
  }

  /// Creates a thread-safe dictionary from an existing dictionary.
  ///
  /// - Parameters:
  ///   - dictionary: The initial key-value pairs.
  ///   - lock: The locking strategy to use. Defaults to `ReadWriteLock`.
  public init(_ dictionary: [Key: Value], lock: LockingStrategy = ReadWriteLock()) {
    self.storage = dictionary
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

  // MARK: - ThreadSafeSubscriptable

  public subscript(index: Key) -> Element? {
    get {
      lock.read {
        guard let value = storage[index] else { return nil }
        return (key: index, value: value)
      }
    }
    set {
      lock.write {
        if let newValue = newValue {
          storage[newValue.key] = newValue.value
        } else {
          storage[index] = nil
        }
      }
    }
  }

  // MARK: - Value-Only Subscript

  /// Subscript for direct value access (traditional dictionary behavior).
  ///
  /// - Parameter key: The key to look up.
  /// - Returns: The value associated with the key, or `nil` if not found.
  public subscript(key key: Key) -> Value? {
    get {
      lock.read { storage[key] }
    }
    set {
      lock.write {
        storage[key] = newValue
      }
    }
  }

  // MARK: - Dictionary-Specific Operations

  /// Updates the value stored in the dictionary for the given key, or adds a new key-value pair if the key doesn't exist.
  ///
  /// - Parameters:
  ///   - value: The new value to store.
  ///   - key: The key to associate with the value.
  /// - Returns: The value that was replaced, or `nil` if a new key-value pair was added.
  @discardableResult
  public func updateValue(_ value: Value, forKey key: Key) -> Value? {
    lock.write {
      storage.updateValue(value, forKey: key)
    }
  }

  /// Removes the given key and its associated value from the dictionary.
  ///
  /// - Parameter key: The key to remove.
  /// - Returns: The value that was removed, or `nil` if the key was not present.
  @discardableResult
  public func removeValue(forKey key: Key) -> Value? {
    lock.write {
      storage.removeValue(forKey: key)
    }
  }

  /// A collection containing just the keys of the dictionary.
  public var keys: [Key] {
    lock.read { Array(storage.keys) }
  }

  /// A collection containing just the values of the dictionary.
  public var values: [Value] {
    lock.read { Array(storage.values) }
  }

  /// Returns a consistent snapshot of all key-value pairs in the dictionary.
  ///
  /// This operation is atomic and returns a copy of the current state.
  ///
  /// - Returns: A dictionary containing all key-value pairs.
  public func snapshot() -> [Key: Value] {
    lock.read { storage }
  }

  /// Executes a closure on each key-value pair in the dictionary.
  ///
  /// The iteration is performed on a consistent snapshot of the dictionary.
  ///
  /// - Parameter body: A closure that takes a key-value pair as parameters.
  /// - Throws: Rethrows any error thrown by the body closure.
  public func forEach(_ body: ((key: Key, value: Value)) throws -> Void) rethrows {
    try lock.read {
      try storage.forEach(body)
    }
  }

  /// Returns an array containing the results of mapping the given closure over the dictionary's key-value pairs.
  ///
  /// - Parameter transform: A mapping closure.
  /// - Returns: An array of transformed elements.
  /// - Throws: Rethrows any error thrown by the transform closure.
  public func map<T>(_ transform: ((key: Key, value: Value)) throws -> T) rethrows -> [T] {
    try lock.read {
      try storage.map(transform)
    }
  }

  /// Returns a dictionary containing the key-value pairs that satisfy the given predicate.
  ///
  /// - Parameter isIncluded: A closure that takes a key-value pair and returns a Boolean value.
  /// - Returns: A dictionary of key-value pairs that satisfy the predicate.
  /// - Throws: Rethrows any error thrown by the isIncluded closure.
  public func filter(_ isIncluded: ((key: Key, value: Value)) throws -> Bool) rethrows -> [Key:
    Value]
  {
    try lock.read {
      try storage.filter(isIncluded)
    }
  }
}

// MARK: - ExpressibleByDictionaryLiteral

extension ThreadSafeDictionary: ExpressibleByDictionaryLiteral {
  public convenience init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(Dictionary(uniqueKeysWithValues: elements))
  }
}

// MARK: - CustomStringConvertible

extension ThreadSafeDictionary: CustomStringConvertible {
  public var description: String {
    lock.read { storage.description }
  }
}
