import Foundation

/// A thread-safe double-ended queue (deque).
///
/// `ThreadSafeDeque` provides synchronized access to a deque data structure using
/// a configurable locking strategy. Elements can be added or removed from both ends.
///
/// **Example:**
/// ```swift
/// let deque = ThreadSafeDeque<Int>()
/// deque.appendBack(1)
/// deque.appendFront(0)
/// print(deque.removeFront()) // Optional(0)
/// print(deque.removeBack())  // Optional(1)
/// ```
public final class ThreadSafeDeque<Element>: ThreadSafeCollection, @unchecked Sendable {
  private var storage: [Element]
  private let lock: LockingStrategy

  // MARK: - Initialization

  /// Creates an empty thread-safe deque with the specified locking strategy.
  ///
  /// - Parameter lock: The locking strategy to use. Defaults to `ReadWriteLock`.
  public init(lock: LockingStrategy = ReadWriteLock()) {
    self.storage = []
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

  // MARK: - Deque Operations

  /// Adds an element to the back of the deque.
  ///
  /// - Parameter element: The element to add.
  public func appendBack(_ element: Element) {
    lock.write {
      storage.append(element)
    }
  }

  /// Adds an element to the front of the deque.
  ///
  /// - Parameter element: The element to add.
  public func appendFront(_ element: Element) {
    lock.write {
      storage.insert(element, at: 0)
    }
  }

  /// Removes and returns the element at the front of the deque.
  ///
  /// - Returns: The front element, or `nil` if the deque is empty.
  @discardableResult
  public func removeFront() -> Element? {
    lock.write {
      guard !storage.isEmpty else { return nil }
      return storage.removeFirst()
    }
  }

  /// Removes and returns the element at the back of the deque.
  ///
  /// - Returns: The back element, or `nil` if the deque is empty.
  @discardableResult
  public func removeBack() -> Element? {
    lock.write {
      storage.popLast()
    }
  }

  /// Returns the element at the front of the deque without removing it.
  ///
  /// - Returns: The front element, or `nil` if the deque is empty.
  public func peekFront() -> Element? {
    lock.read {
      storage.first
    }
  }

  /// Returns the element at the back of the deque without removing it.
  ///
  /// - Returns: The back element, or `nil` if the deque is empty.
  public func peekBack() -> Element? {
    lock.read {
      storage.last
    }
  }

  /// Returns a consistent snapshot of all elements in the deque.
  ///
  /// - Returns: An array containing all elements (front to back).
  public func snapshot() -> [Element] {
    lock.read { storage }
  }
}

// MARK: - CustomStringConvertible

extension ThreadSafeDeque: CustomStringConvertible {
  public var description: String {
    lock.read { "Deque(\(storage))" }
  }
}
