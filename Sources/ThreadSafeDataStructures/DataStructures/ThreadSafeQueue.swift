import Foundation

/// A thread-safe FIFO (First-In-First-Out) queue.
///
/// `ThreadSafeQueue` provides synchronized access to a queue data structure using
/// a configurable locking strategy. All operations are atomic and thread-safe.
///
/// **Example:**
/// ```swift
/// let queue = ThreadSafeQueue<String>()
/// queue.enqueue("first")
/// queue.enqueue("second")
/// print(queue.dequeue()) // Optional("first")
/// ```
///
/// **Concurrency:**
/// ```swift
/// await withTaskGroup(of: Void.self) { group in
///     for i in 0..<100 {
///         group.addTask {
///             queue.enqueue(i)
///         }
///     }
/// }
/// ```
public final class ThreadSafeQueue<Element>: ThreadSafeCollection, @unchecked Sendable {
  private var storage: [Element]
  private let lock: LockingStrategy

  // MARK: - Initialization

  /// Creates an empty thread-safe queue with the specified locking strategy.
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

  // MARK: - Queue Operations

  /// Adds an element to the end of the queue.
  ///
  /// - Parameter element: The element to add.
  public func enqueue(_ element: Element) {
    lock.write {
      storage.append(element)
    }
  }

  /// Removes and returns the element at the front of the queue.
  ///
  /// - Returns: The first element in the queue, or `nil` if the queue is empty.
  @discardableResult
  public func dequeue() -> Element? {
    lock.write {
      guard !storage.isEmpty else { return nil }
      return storage.removeFirst()
    }
  }

  /// Returns the element at the front of the queue without removing it.
  ///
  /// - Returns: The first element in the queue, or `nil` if the queue is empty.
  public func peek() -> Element? {
    lock.read {
      storage.first
    }
  }

  // MARK: - Functional Operations

  /// Returns a consistent snapshot of all elements in the queue.
  ///
  /// Elements are returned in FIFO order.
  ///
  /// - Returns: An array containing all elements in queue order.
  public func snapshot() -> [Element] {
    lock.read { storage }
  }

  /// Executes a closure on each element in the queue.
  ///
  /// The iteration is performed on a consistent snapshot of the queue in FIFO order.
  ///
  /// - Parameter body: A closure that takes an element as a parameter.
  /// - Throws: Rethrows any error thrown by the body closure.
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try lock.read {
      try storage.forEach(body)
    }
  }

  /// Returns an array containing the results of mapping the given closure over the queue's elements.
  ///
  /// - Parameter transform: A mapping closure.
  /// - Returns: An array of transformed elements in queue order.
  /// - Throws: Rethrows any error thrown by the transform closure.
  public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
    try lock.read {
      try storage.map(transform)
    }
  }
}

// MARK: - CustomStringConvertible

extension ThreadSafeQueue: CustomStringConvertible {
  public var description: String {
    lock.read { "Queue(\(storage))" }
  }
}
