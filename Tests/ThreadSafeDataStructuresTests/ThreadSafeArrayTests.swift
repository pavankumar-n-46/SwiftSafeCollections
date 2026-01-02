import Testing

@testable import ThreadSafeDataStructures

// MARK: - Basic Operations Tests

@Suite("ThreadSafeArray Basic Operations")
struct ThreadSafeArrayBasicTests {

  @Test("Initialize empty array")
  func testInitializeEmpty() {
    let array = ThreadSafeArray<Int>()
    #expect(array.isEmpty)
    #expect(array.count == 0)
  }

  @Test("Initialize with array literal")
  func testInitializeWithLiteral() {
    let array: ThreadSafeArray<String> = ["a", "b", "c"]
    #expect(!array.isEmpty)
    #expect(array.count == 3)
  }

  @Test("Append elements")
  func testAppend() {
    let array = ThreadSafeArray<Int>()
    array.append(1)
    array.append(2)
    array.append(3)

    #expect(array.count == 3)
    #expect(array[0] == 1)
    #expect(array[1] == 2)
    #expect(array[2] == 3)
  }

  @Test("Insert at index")
  func testInsert() {
    let array: ThreadSafeArray<String> = ["a", "c"]
    array.insert("b", at: 1)

    #expect(array.count == 3)
    #expect(array[0] == "a")
    #expect(array[1] == "b")
    #expect(array[2] == "c")
  }

  @Test("Remove at index")
  func testRemove() {
    let array: ThreadSafeArray<Int> = [1, 2, 3, 4, 5]
    let removed = array.remove(at: 2)

    #expect(removed == 3)
    #expect(array.count == 4)
    #expect(array[2] == 4)
  }

  @Test("Subscript get and set")
  func testSubscript() {
    let array: ThreadSafeArray<Int> = [10, 20, 30]

    #expect(array[0] == 10)
    #expect(array[1] == 20)

    array[1] = 25
    #expect(array[1] == 25)
  }

  @Test("First and last elements")
  func testFirstLast() {
    let array: ThreadSafeArray<String> = ["first", "middle", "last"]

    #expect(array.first == "first")
    #expect(array.last == "last")
  }

  @Test("First and last on empty array")
  func testFirstLastEmpty() {
    let array = ThreadSafeArray<Int>()

    #expect(array.first == nil)
    #expect(array.last == nil)
  }

  @Test("Remove all elements")
  func testRemoveAll() {
    let array: ThreadSafeArray<Int> = [1, 2, 3, 4, 5]
    array.removeAll()

    #expect(array.isEmpty)
    #expect(array.count == 0)
  }
}

// MARK: - Edge Cases Tests

@Suite("ThreadSafeArray Edge Cases")
struct ThreadSafeArrayEdgeCaseTests {

  @Test("Subscript out of bounds returns nil")
  func testSubscriptOutOfBounds() {
    let array: ThreadSafeArray<Int> = [1, 2, 3]

    #expect(array[10] == nil)
    #expect(array[-1] == nil)
  }

  @Test("Contains element")
  func testContains() {
    let array: ThreadSafeArray<Int> = [1, 2, 3, 4, 5]

    #expect(array.contains(3))
    #expect(!array.contains(10))
  }

  @Test("Snapshot returns copy")
  func testSnapshot() {
    let array: ThreadSafeArray<Int> = [1, 2, 3]
    let snapshot = array.snapshot()

    #expect(snapshot == [1, 2, 3])

    // Modify original
    array.append(4)

    // Snapshot should be unchanged
    #expect(snapshot == [1, 2, 3])
    #expect(array.count == 4)
  }
}

// MARK: - Functional Operations Tests

@Suite("ThreadSafeArray Functional Operations")
struct ThreadSafeArrayFunctionalTests {

  @Test("ForEach iteration")
  func testForEach() {
    let array: ThreadSafeArray<Int> = [1, 2, 3, 4, 5]
    var sum = 0

    array.forEach { sum += $0 }

    #expect(sum == 15)
  }

  @Test("Map transformation")
  func testMap() {
    let array: ThreadSafeArray<Int> = [1, 2, 3, 4, 5]
    let doubled = array.map { $0 * 2 }

    #expect(doubled == [2, 4, 6, 8, 10])
  }

  @Test("Filter elements")
  func testFilter() {
    let array: ThreadSafeArray<Int> = [1, 2, 3, 4, 5, 6]
    let evens = array.filter { $0 % 2 == 0 }

    #expect(evens == [2, 4, 6])
  }
}

// MARK: - Concurrency Tests

@Suite("ThreadSafeArray Concurrency")
struct ThreadSafeArrayConcurrencyTests {

  @Test("Concurrent appends")
  func testConcurrentAppends() async {
    let array = ThreadSafeArray<Int>()

    await withTaskGroup(of: Void.self) { group in
      for i in 0..<100 {
        group.addTask {
          array.append(i)
        }
      }
    }

    #expect(array.count == 100)
  }

  @Test("Concurrent reads and writes")
  func testConcurrentReadsWrites() async {
    let array: ThreadSafeArray<Int> = Array(0..<50).reduce(into: ThreadSafeArray<Int>()) {
      $0.append($1)
    }

    await withTaskGroup(of: Void.self) { group in
      // Writers
      for i in 50..<100 {
        group.addTask {
          array.append(i)
        }
      }

      // Readers
      for _ in 0..<50 {
        group.addTask {
          _ = array.snapshot()
        }
      }
    }

    #expect(array.count == 100)
  }

  @Test("Concurrent modifications")
  func testConcurrentModifications() async {
    let array: ThreadSafeArray<Int> = [0, 0, 0, 0, 0]

    await withTaskGroup(of: Void.self) { group in
      for i in 0..<5 {
        group.addTask {
          array[i] = i + 1
        }
      }
    }

    let snapshot = array.snapshot().sorted()
    #expect(snapshot == [1, 2, 3, 4, 5])
  }
}
