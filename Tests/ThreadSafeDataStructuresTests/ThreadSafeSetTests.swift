import Testing

@testable import ThreadSafeDataStructures

// MARK: - Basic Operations Tests

@Suite("ThreadSafeSet Basic Operations")
struct ThreadSafeSetBasicTests {

  @Test("Initialize empty set")
  func testInitializeEmpty() {
    let set = ThreadSafeSet<Int>()
    #expect(set.isEmpty)
    #expect(set.count == 0)
  }

  @Test("Initialize with array literal")
  func testInitializeWithLiteral() {
    let set: ThreadSafeSet<String> = ["a", "b", "c"]
    #expect(!set.isEmpty)
    #expect(set.count == 3)
  }

  @Test("Insert elements")
  func testInsert() {
    let set = ThreadSafeSet<Int>()

    let (inserted1, _) = set.insert(1)
    let (inserted2, _) = set.insert(2)
    let (inserted3, _) = set.insert(1)  // Duplicate

    #expect(inserted1 == true)
    #expect(inserted2 == true)
    #expect(inserted3 == false)  // Already exists
    #expect(set.count == 2)
  }

  @Test("Contains element")
  func testContains() {
    let set: ThreadSafeSet<String> = ["apple", "banana", "cherry"]

    #expect(set.contains("apple"))
    #expect(set.contains("banana"))
    #expect(!set.contains("orange"))
  }

  @Test("Remove element")
  func testRemove() {
    let set: ThreadSafeSet<Int> = [1, 2, 3, 4, 5]

    let removed = set.remove(3)

    #expect(removed == 3)
    #expect(set.count == 4)
    #expect(!set.contains(3))
  }

  @Test("Remove non-existent element")
  func testRemoveNonExistent() {
    let set: ThreadSafeSet<Int> = [1, 2, 3]

    let removed = set.remove(10)

    #expect(removed == nil)
    #expect(set.count == 3)
  }

  @Test("Remove all elements")
  func testRemoveAll() {
    let set: ThreadSafeSet<Int> = [1, 2, 3, 4, 5]
    set.removeAll()

    #expect(set.isEmpty)
    #expect(set.count == 0)
  }
}

// MARK: - Set Operations Tests

@Suite("ThreadSafeSet Set Operations")
struct ThreadSafeSetOperationsTests {

  @Test("Union")
  func testUnion() {
    let set1: ThreadSafeSet<Int> = [1, 2, 3]
    let set2: ThreadSafeSet<Int> = [3, 4, 5]

    let union = set1.union(set2)

    #expect(union.count == 5)
    #expect(union.contains(1))
    #expect(union.contains(5))
  }

  @Test("Intersection")
  func testIntersection() {
    let set1: ThreadSafeSet<Int> = [1, 2, 3, 4]
    let set2: ThreadSafeSet<Int> = [3, 4, 5, 6]

    let intersection = set1.intersection(set2)

    #expect(intersection.count == 2)
    #expect(intersection.contains(3))
    #expect(intersection.contains(4))
    #expect(!intersection.contains(1))
  }

  @Test("Subtracting")
  func testSubtracting() {
    let set1: ThreadSafeSet<Int> = [1, 2, 3, 4]
    let set2: ThreadSafeSet<Int> = [3, 4, 5]

    let difference = set1.subtracting(set2)

    #expect(difference.count == 2)
    #expect(difference.contains(1))
    #expect(difference.contains(2))
    #expect(!difference.contains(3))
  }

  @Test("Symmetric difference")
  func testSymmetricDifference() {
    let set1: ThreadSafeSet<Int> = [1, 2, 3]
    let set2: ThreadSafeSet<Int> = [3, 4, 5]

    let symDiff = set1.symmetricDifference(set2)

    #expect(symDiff.count == 4)
    #expect(symDiff.contains(1))
    #expect(symDiff.contains(5))
    #expect(!symDiff.contains(3))
  }

  @Test("Is subset")
  func testIsSubset() {
    let set1: ThreadSafeSet<Int> = [1, 2]
    let set2: ThreadSafeSet<Int> = [1, 2, 3, 4]

    #expect(set1.isSubset(of: set2))
    #expect(!set2.isSubset(of: set1))
  }

  @Test("Is superset")
  func testIsSuperset() {
    let set1: ThreadSafeSet<Int> = [1, 2, 3, 4]
    let set2: ThreadSafeSet<Int> = [2, 3]

    #expect(set1.isSuperset(of: set2))
    #expect(!set2.isSuperset(of: set1))
  }

  @Test("Is disjoint")
  func testIsDisjoint() {
    let set1: ThreadSafeSet<Int> = [1, 2, 3]
    let set2: ThreadSafeSet<Int> = [4, 5, 6]
    let set3: ThreadSafeSet<Int> = [3, 4, 5]

    #expect(set1.isDisjoint(with: set2))
    #expect(!set1.isDisjoint(with: set3))
  }
}

// MARK: - Functional Operations Tests

@Suite("ThreadSafeSet Functional Operations")
struct ThreadSafeSetFunctionalTests {

  @Test("ForEach iteration")
  func testForEach() {
    let set: ThreadSafeSet<Int> = [1, 2, 3, 4, 5]
    var sum = 0

    set.forEach { sum += $0 }

    #expect(sum == 15)
  }

  @Test("Map transformation")
  func testMap() {
    let set: ThreadSafeSet<Int> = [1, 2, 3]
    let doubled = set.map { $0 * 2 }.sorted()

    #expect(doubled == [2, 4, 6])
  }

  @Test("Filter elements")
  func testFilter() {
    let set: ThreadSafeSet<Int> = [1, 2, 3, 4, 5, 6]
    let evens = set.filter { $0 % 2 == 0 }

    #expect(evens.count == 3)
    #expect(evens.contains(2))
    #expect(evens.contains(4))
    #expect(evens.contains(6))
  }

  @Test("Snapshot returns copy")
  func testSnapshot() {
    let set: ThreadSafeSet<Int> = [1, 2, 3]
    let snapshot = set.snapshot()

    #expect(snapshot == Set([1, 2, 3]))

    // Modify original
    set.insert(4)

    // Snapshot should be unchanged
    #expect(snapshot == Set([1, 2, 3]))
    #expect(set.count == 4)
  }
}

// MARK: - Concurrency Tests

@Suite("ThreadSafeSet Concurrency")
struct ThreadSafeSetConcurrencyTests {

  @Test("Concurrent inserts")
  func testConcurrentInserts() async {
    let set = ThreadSafeSet<Int>()

    await withTaskGroup(of: Void.self) { group in
      for i in 0..<100 {
        group.addTask {
          set.insert(i)
        }
      }
    }

    #expect(set.count == 100)
  }

  @Test("Concurrent reads and writes")
  func testConcurrentReadsWrites() async {
    let set: ThreadSafeSet<Int> = Array(0..<50).reduce(into: ThreadSafeSet<Int>()) {
      $0.insert($1)
    }

    await withTaskGroup(of: Void.self) { group in
      // Writers
      for i in 50..<100 {
        group.addTask {
          set.insert(i)
        }
      }

      // Readers
      for _ in 0..<50 {
        group.addTask {
          _ = set.snapshot()
        }
      }
    }

    #expect(set.count == 100)
  }

  @Test("Concurrent duplicate inserts")
  func testConcurrentDuplicates() async {
    let set = ThreadSafeSet<Int>()

    await withTaskGroup(of: Void.self) { group in
      // Multiple tasks trying to insert same values
      for _ in 0..<10 {
        for i in 0..<10 {
          group.addTask {
            set.insert(i)
          }
        }
      }
    }

    // Should only have 10 unique elements
    #expect(set.count == 10)
  }
}
