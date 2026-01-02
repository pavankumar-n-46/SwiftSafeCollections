import Testing

@testable import ThreadSafeDataStructures

// MARK: - Basic Operations Tests

@Suite("ThreadSafeDeque Basic Operations")
struct ThreadSafeDequeBasicTests {

  @Test("Initialize empty deque")
  func testInitializeEmpty() {
    let deque = ThreadSafeDeque<Int>()
    #expect(deque.isEmpty)
    #expect(deque.count == 0)
  }

  @Test("Append to back")
  func testAppendBack() {
    let deque = ThreadSafeDeque<String>()

    deque.appendBack("first")
    deque.appendBack("second")

    #expect(deque.count == 2)
  }

  @Test("Append to front")
  func testAppendFront() {
    let deque = ThreadSafeDeque<Int>()

    deque.appendFront(1)
    deque.appendFront(2)

    #expect(deque.count == 2)
  }

  @Test("Remove from front")
  func testRemoveFront() {
    let deque = ThreadSafeDeque<Int>()
    deque.appendBack(1)
    deque.appendBack(2)
    deque.appendBack(3)

    #expect(deque.removeFront() == 1)
    #expect(deque.removeFront() == 2)
    #expect(deque.count == 1)
  }

  @Test("Remove from back")
  func testRemoveBack() {
    let deque = ThreadSafeDeque<Int>()
    deque.appendBack(1)
    deque.appendBack(2)
    deque.appendBack(3)

    #expect(deque.removeBack() == 3)
    #expect(deque.removeBack() == 2)
    #expect(deque.count == 1)
  }

  @Test("Peek front and back")
  func testPeek() {
    let deque = ThreadSafeDeque<String>()
    deque.appendBack("first")
    deque.appendBack("second")
    deque.appendBack("third")

    #expect(deque.peekFront() == "first")
    #expect(deque.peekBack() == "third")
    #expect(deque.count == 3)  // Peek doesn't remove
  }

  @Test("Remove all elements")
  func testRemoveAll() {
    let deque = ThreadSafeDeque<Int>()
    deque.appendBack(1)
    deque.appendBack(2)
    deque.appendBack(3)

    deque.removeAll()

    #expect(deque.isEmpty)
    #expect(deque.count == 0)
  }
}

// MARK: - Concurrency Tests

@Suite("ThreadSafeDeque Concurrency")
struct ThreadSafeDequeConcurrencyTests {

  @Test("Concurrent appends")
  func testConcurrentAppends() async {
    let deque = ThreadSafeDeque<Int>()

    await withTaskGroup(of: Void.self) { group in
      for i in 0..<50 {
        group.addTask {
          deque.appendFront(i)
        }
      }
      for i in 50..<100 {
        group.addTask {
          deque.appendBack(i)
        }
      }
    }

    #expect(deque.count == 100)
  }

  @Test("Concurrent operations")
  func testConcurrentOperations() async {
    let deque = ThreadSafeDeque<Int>()

    // Pre-populate
    for i in 0..<50 {
      deque.appendBack(i)
    }

    await withTaskGroup(of: Void.self) { group in
      // Append
      for i in 50..<75 {
        group.addTask {
          deque.appendBack(i)
        }
      }

      // Remove
      for _ in 0..<25 {
        group.addTask {
          _ = deque.removeFront()
        }
      }
    }

    #expect(deque.count == 50)
  }
}
