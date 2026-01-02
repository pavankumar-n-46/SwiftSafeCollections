import Foundation

/// Protocol for thread-safe collections that support subscript access.
///
/// Enables index-based (for arrays) or key-based (for dictionaries) access
/// with thread-safe guarantees.
public protocol ThreadSafeSubscriptable: ThreadSafeCollection {
  /// The type used for subscript access (e.g., `Int` for arrays, `Key` for dictionaries).
  associatedtype Index

  /// Accesses the element at the specified index or key.
  ///
  /// Returns `nil` if the index/key doesn't exist or is out of bounds.
  /// Setting a value to `nil` removes the element (for dictionaries).
  ///
  /// - Parameter index: The index or key to access.
  /// - Returns: The element at the specified index/key, or `nil` if not found.
  subscript(index: Index) -> Element? { get set }
}
