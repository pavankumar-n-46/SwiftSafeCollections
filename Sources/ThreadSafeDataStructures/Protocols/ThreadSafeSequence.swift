import Foundation

/// Protocol for thread-safe collections that support iteration.
///
/// Provides functional programming operations that execute atomically
/// on a consistent snapshot of the collection.
public protocol ThreadSafeSequence: ThreadSafeCollection {
  /// Executes a closure on each element in the collection.
  ///
  /// The iteration is performed on a consistent snapshot of the collection,
  /// ensuring thread-safe access even if the collection is modified concurrently.
  ///
  /// - Parameter body: A closure that takes an element as a parameter.
  /// - Throws: Rethrows any error thrown by the body closure.
  func forEach(_ body: (Element) throws -> Void) rethrows

  /// Returns an array containing the results of mapping the given closure over the collection.
  ///
  /// The mapping is performed on a consistent snapshot of the collection.
  ///
  /// - Parameter transform: A mapping closure.
  /// - Returns: An array of transformed elements.
  /// - Throws: Rethrows any error thrown by the transform closure.
  func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]

  /// Returns an array containing the elements that satisfy the given predicate.
  ///
  /// The filtering is performed on a consistent snapshot of the collection.
  ///
  /// - Parameter isIncluded: A closure that takes an element and returns a Boolean value.
  /// - Returns: An array of elements that satisfy the predicate.
  /// - Throws: Rethrows any error thrown by the isIncluded closure.
  func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element]

  /// Returns a consistent snapshot of all elements in the collection.
  ///
  /// This operation is atomic and returns a copy of the current state.
  ///
  /// - Returns: An array containing all elements.
  func snapshot() -> [Element]
}
