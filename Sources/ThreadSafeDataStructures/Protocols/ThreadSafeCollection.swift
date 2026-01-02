import Foundation

/// Base protocol for all thread-safe collection types.
///
/// Provides fundamental operations common to all thread-safe data structures.
/// Conforming types guarantee thread-safe access to their underlying storage.
public protocol ThreadSafeCollection: Sendable {
  /// The type of elements stored in the collection.
  associatedtype Element

  /// The number of elements in the collection.
  ///
  /// This property is thread-safe and returns a consistent snapshot.
  var count: Int { get }

  /// A Boolean value indicating whether the collection is empty.
  ///
  /// This property is thread-safe and returns a consistent snapshot.
  var isEmpty: Bool { get }

  /// Removes all elements from the collection.
  ///
  /// This operation is thread-safe and atomic.
  func removeAll()
}
