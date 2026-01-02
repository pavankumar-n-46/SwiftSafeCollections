import Testing

@testable import ThreadSafeDataStructures

// MARK: - Basic Operations Tests

@Suite("ThreadSafeDictionary Basic Operations")
struct ThreadSafeDictionaryBasicTests {

  @Test("Initialize empty dictionary")
  func testInitializeEmpty() {
    let dict = ThreadSafeDictionary<String, Int>()
    #expect(dict.isEmpty)
    #expect(dict.count == 0)
  }

  @Test("Initialize with dictionary literal")
  func testInitializeWithLiteral() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]
    #expect(!dict.isEmpty)
    #expect(dict.count == 3)
  }

  @Test("Set and get values")
  func testSetGet() {
    let dict = ThreadSafeDictionary<String, Int>()
    dict[key: "name"] = 42
    dict[key: "age"] = 25

    #expect(dict[key: "name"] == 42)
    #expect(dict[key: "age"] == 25)
    #expect(dict.count == 2)
  }

  @Test("Update existing value")
  func testUpdate() {
    let dict: ThreadSafeDictionary<String, Int> = ["key": 10]

    let oldValue = dict.updateValue(20, forKey: "key")

    #expect(oldValue == 10)
    #expect(dict[key: "key"] == 20)
  }

  @Test("Remove value")
  func testRemove() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

    let removed = dict.removeValue(forKey: "b")

    #expect(removed == 2)
    #expect(dict.count == 2)
    #expect(dict[key: "b"] == nil)
  }

  @Test("Subscript set to nil removes key")
  func testSubscriptRemove() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1, "b": 2]

    dict[key: "a"] = nil

    #expect(dict[key: "a"] == nil)
    #expect(dict.count == 1)
  }

  @Test("Keys and values")
  func testKeysValues() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

    let keys = dict.keys.sorted()
    let values = dict.values.sorted()

    #expect(keys == ["a", "b", "c"])
    #expect(values == [1, 2, 3])
  }

  @Test("Remove all elements")
  func testRemoveAll() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]
    dict.removeAll()

    #expect(dict.isEmpty)
    #expect(dict.count == 0)
  }
}

// MARK: - Edge Cases Tests

@Suite("ThreadSafeDictionary Edge Cases")
struct ThreadSafeDictionaryEdgeCaseTests {

  @Test("Get non-existent key returns nil")
  func testNonExistentKey() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1]

    #expect(dict[key: "nonexistent"] == nil)
  }

  @Test("Update non-existent key returns nil")
  func testUpdateNonExistent() {
    let dict = ThreadSafeDictionary<String, Int>()

    let oldValue = dict.updateValue(10, forKey: "new")

    #expect(oldValue == nil)
    #expect(dict[key: "new"] == 10)
  }

  @Test("Remove non-existent key returns nil")
  func testRemoveNonExistent() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1]

    let removed = dict.removeValue(forKey: "nonexistent")

    #expect(removed == nil)
    #expect(dict.count == 1)
  }

  @Test("Snapshot returns copy")
  func testSnapshot() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1, "b": 2]
    let snapshot = dict.snapshot()

    #expect(snapshot == ["a": 1, "b": 2])

    // Modify original
    dict[key: "c"] = 3

    // Snapshot should be unchanged
    #expect(snapshot == ["a": 1, "b": 2])
    #expect(dict.count == 3)
  }
}

// MARK: - Functional Operations Tests

@Suite("ThreadSafeDictionary Functional Operations")
struct ThreadSafeDictionaryFunctionalTests {

  @Test("ForEach iteration")
  func testForEach() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]
    var sum = 0

    dict.forEach { _, value in
      sum += value
    }

    #expect(sum == 6)
  }

  @Test("Map transformation")
  func testMap() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]
    let doubled = dict.map { $0.value * 2 }.sorted()

    #expect(doubled == [2, 4, 6])
  }

  @Test("Filter elements")
  func testFilter() {
    let dict: ThreadSafeDictionary<String, Int> = ["a": 1, "b": 2, "c": 3, "d": 4]
    let filtered = dict.filter { $0.value % 2 == 0 }

    #expect(filtered.count == 2)
    #expect(filtered["b"] == 2)
    #expect(filtered["d"] == 4)
  }
}

// MARK: - Concurrency Tests

@Suite("ThreadSafeDictionary Concurrency")
struct ThreadSafeDictionaryConcurrencyTests {

  @Test("Concurrent writes")
  func testConcurrentWrites() async {
    let dict = ThreadSafeDictionary<Int, String>()

    await withTaskGroup(of: Void.self) { group in
      for i in 0..<100 {
        group.addTask {
          dict[key: i] = "value\(i)"
        }
      }
    }

    #expect(dict.count == 100)
  }

  @Test("Concurrent reads and writes")
  func testConcurrentReadsWrites() async {
    let dict: ThreadSafeDictionary<Int, String> = Dictionary(
      uniqueKeysWithValues: (0..<50).map { ($0, "value\($0)") }
    ).reduce(into: ThreadSafeDictionary<Int, String>()) { result, pair in
      result[key: pair.key] = pair.value
    }

    await withTaskGroup(of: Void.self) { group in
      // Writers
      for i in 50..<100 {
        group.addTask {
          dict[key: i] = "value\(i)"
        }
      }

      // Readers
      for _ in 0..<50 {
        group.addTask {
          _ = dict.snapshot()
        }
      }
    }

    #expect(dict.count == 100)
  }

  @Test("Concurrent modifications")
  func testConcurrentModifications() async {
    let dict: ThreadSafeDictionary<Int, Int> = [0: 0, 1: 0, 2: 0, 3: 0, 4: 0]

    await withTaskGroup(of: Void.self) { group in
      for i in 0..<5 {
        group.addTask {
          dict[key: i] = i + 1
        }
      }
    }

    let values = dict.values.sorted()
    #expect(values == [1, 2, 3, 4, 5])
  }
}
