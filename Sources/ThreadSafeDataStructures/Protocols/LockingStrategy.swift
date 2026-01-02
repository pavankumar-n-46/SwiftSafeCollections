import Foundation

/// Protocol defining a synchronization strategy for thread-safe operations.
///
/// Implementations provide different locking mechanisms optimized for various use cases.
/// All implementations use POSIX-compatible primitives for cross-platform support (macOS, iOS, Linux).
public protocol LockingStrategy: Sendable {
  /// Executes a read operation with appropriate synchronization.
  ///
  /// - Parameter work: The closure to execute while holding the read lock.
  /// - Returns: The result of the work closure.
  /// - Throws: Rethrows any error thrown by the work closure.
  func read<T>(_ work: () throws -> T) rethrows -> T

  /// Executes a write operation with appropriate synchronization.
  ///
  /// - Parameter work: The closure to execute while holding the write lock.
  /// - Returns: The result of the work closure.
  /// - Throws: Rethrows any error thrown by the work closure.
  func write<T>(_ work: () throws -> T) rethrows -> T
}

// MARK: - ReadWriteLock

/// A reader-writer lock using `pthread_rwlock_t`.
///
/// Optimized for read-heavy workloads where multiple readers can access concurrently,
/// but writes require exclusive access.
///
/// **Use when:**
/// - Read operations significantly outnumber writes (e.g., caches, configuration)
/// - Cross-platform compatibility is required (POSIX standard)
public final class ReadWriteLock: LockingStrategy, @unchecked Sendable {
  private var lock = pthread_rwlock_t()

  public init() {
    pthread_rwlock_init(&lock, nil)
  }

  deinit {
    pthread_rwlock_destroy(&lock)
  }

  public func read<T>(_ work: () throws -> T) rethrows -> T {
    pthread_rwlock_rdlock(&lock)
    defer { pthread_rwlock_unlock(&lock) }
    return try work()
  }

  public func write<T>(_ work: () throws -> T) rethrows -> T {
    pthread_rwlock_wrlock(&lock)
    defer { pthread_rwlock_unlock(&lock) }
    return try work()
  }
}

// MARK: - MutexLock

/// A simple mutex lock using `pthread_mutex_t`.
///
/// Provides exclusive access for both reads and writes. Simpler than read-write locks
/// but doesn't allow concurrent readers.
///
/// **Use when:**
/// - Write operations are frequent
/// - Simplicity is preferred over read optimization
/// - Cross-platform compatibility is required (POSIX standard)
public final class MutexLock: LockingStrategy, @unchecked Sendable {
  private var mutex = pthread_mutex_t()

  public init() {
    pthread_mutex_init(&mutex, nil)
  }

  deinit {
    pthread_mutex_destroy(&mutex)
  }

  public func read<T>(_ work: () throws -> T) rethrows -> T {
    pthread_mutex_lock(&mutex)
    defer { pthread_mutex_unlock(&mutex) }
    return try work()
  }

  public func write<T>(_ work: () throws -> T) rethrows -> T {
    pthread_mutex_lock(&mutex)
    defer { pthread_mutex_unlock(&mutex) }
    return try work()
  }
}

// MARK: - DispatchQueueLock

/// A lock using Grand Central Dispatch (GCD) with barrier flags.
///
/// Uses a concurrent queue where reads execute concurrently and writes use barriers
/// for exclusive access. Familiar API for iOS/macOS developers.
///
/// **Use when:**
/// - You prefer GCD's familiar API
/// - Integration with existing GCD-based code
/// - Available on all Swift platforms
public final class DispatchQueueLock: LockingStrategy, @unchecked Sendable {
  private let queue: DispatchQueue

  /// Creates a new DispatchQueue-based lock.
  ///
  /// - Parameter label: A string label to attach to the queue for debugging.
  public init(label: String = "com.threadsafe.dispatchqueue") {
    self.queue = DispatchQueue(label: label, attributes: .concurrent)
  }

  public func read<T>(_ work: () throws -> T) rethrows -> T {
    try queue.sync {
      try work()
    }
  }

  public func write<T>(_ work: () throws -> T) rethrows -> T {
    try queue.sync(flags: .barrier) {
      try work()
    }
  }
}
