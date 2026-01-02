import Foundation

/// A thread-safe LIFO (Last-In-First-Out) stack.
///
/// `ThreadSafeStack` provides synchronized access to a stack data structure using
/// a configurable locking strategy. All operations are atomic and thread-safe.
///
/// **Example:**
/// ```swift
/// let stack = ThreadSafeStack<String>()
/// stack.push("first")
/// stack.push("second")
/// print(stack.pop()) // Optional("second")
/// ```
public final class ThreadSafeStack<Element>: ThreadSafeCollection, @unchecked Sendable {
  private var storage: [Element]
  private let lock: LockingStrategy

  // MARK: - Initialization

  /// Creates an empty thread-safe stack with the specified locking strategy.
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

  // MARK: - Stack Operations

  /// Pushes an element onto the top of the stack.
  ///
  /// - Parameter element: The element to push.
  public func push(_ element: Element) {
    lock.write {
      storage.append(element)
    }
  }

  /// Removes and returns the element at the top of the stack.
  ///
  /// - Returns: The top element, or `nil` if the stack is empty.
  @discardableResult
  public func pop() -> Element? {
    lock.write {
      storage.popLast()
    }
  }

  /// Returns the element at the top of the stack without removing it.
  ///
  /// - Returns: The top element, or `nil` if the stack is empty.
  public func peek() -> Element? {
    lock.read {
      storage.last
    }
  }

  /// Returns a consistent snapshot of all elements in the stack.
  ///
  /// - Returns: An array containing all elements (bottom to top).
  public func snapshot() -> [Element] {
    lock.read { storage }
  }
}

// MARK: - CustomStringConvertible

extension ThreadSafeStack: CustomStringConvertible {
  public var description: String {
    lock.read { "Stack(\(storage))" }
  }
}
