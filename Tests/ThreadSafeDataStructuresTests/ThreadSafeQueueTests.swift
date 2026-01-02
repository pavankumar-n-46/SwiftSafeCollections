import Testing

@testable import ThreadSafeDataStructures

// MARK: - Basic Operations Tests

@Suite("ThreadSafeQueue Basic Operations")
struct ThreadSafeQueueBasicTests {

  @Test("Initialize empty queue")
  func testInitializeEmpty() {
    let queue = ThreadSafeQueue<Int>()
    #expect(queue.isEmpty)
    #expect(queue.count == 0)
  }

  @Test("Enqueue elements")
  func testEnqueue() {
    let queue = ThreadSafeQueue<String>()

    queue.enqueue("first")
    queue.enqueue("second")
    queue.enqueue("third")

    #expect(queue.count == 3)
    #expect(!queue.isEmpty)
  }

  @Test("Dequeue elements (FIFO)")
  func testDequeue() {
    let queue = ThreadSafeQueue<Int>()
    queue.enqueue(1)
    queue.enqueue(2)
    queue.enqueue(3)

    #expect(queue.dequeue() == 1)
    #expect(queue.dequeue() == 2)
    #expect(queue.dequeue() == 3)
    #expect(queue.isEmpty)
  }

  @Test("Dequeue from empty queue")
  func testDequeueEmpty() {
    let queue = ThreadSafeQueue<Int>()

    #expect(queue.dequeue() == nil)
  }

  @Test("Peek first element")
  func testPeek() {
    let queue = ThreadSafeQueue<String>()
    queue.enqueue("first")
    queue.enqueue("second")

    #expect(queue.peek() == "first")
    #expect(queue.count == 2)  // Peek doesn't remove
  }

  @Test("Peek empty queue")
  func testPeekEmpty() {
    let queue = ThreadSafeQueue<Int>()

    #expect(queue.peek() == nil)
  }

  @Test("Remove all elements")
  func testRemoveAll() {
    let queue = ThreadSafeQueue<Int>()
    queue.enqueue(1)
    queue.enqueue(2)
    queue.enqueue(3)

    queue.removeAll()

    #expect(queue.isEmpty)
    #expect(queue.count == 0)
  }
}

// MARK: - Functional Operations Tests

@Suite("ThreadSafeQueue Functional Operations")
struct ThreadSafeQueueFunctionalTests {

  @Test("ForEach iteration")
  func testForEach() {
    let queue = ThreadSafeQueue<Int>()
    queue.enqueue(1)
    queue.enqueue(2)
    queue.enqueue(3)

    var sum = 0
    queue.forEach { sum += $0 }

    #expect(sum == 6)
  }

  @Test("Map transformation")
  func testMap() {
    let queue = ThreadSafeQueue<Int>()
    queue.enqueue(1)
    queue.enqueue(2)
    queue.enqueue(3)

    let doubled = queue.map { $0 * 2 }

    #expect(doubled == [2, 4, 6])
  }

  @Test("Snapshot returns copy")
  func testSnapshot() {
    let queue = ThreadSafeQueue<Int>()
    queue.enqueue(1)
    queue.enqueue(2)

    let snapshot = queue.snapshot()

    #expect(snapshot == [1, 2])

    queue.enqueue(3)

    #expect(snapshot == [1, 2])
    #expect(queue.count == 3)
  }
}

// MARK: - Concurrency Tests

@Suite("ThreadSafeQueue Concurrency")
struct ThreadSafeQueueConcurrencyTests {

  @Test("Concurrent enqueues")
  func testConcurrentEnqueues() async {
    let queue = ThreadSafeQueue<Int>()

    await withTaskGroup(of: Void.self) { group in
      for i in 0..<100 {
        group.addTask {
          queue.enqueue(i)
        }
      }
    }

    #expect(queue.count == 100)
  }

  @Test("Concurrent enqueues and dequeues")
  func testConcurrentEnqueueDequeue() async {
    let queue = ThreadSafeQueue<Int>()

    // Pre-populate
    for i in 0..<50 {
      queue.enqueue(i)
    }

    await withTaskGroup(of: Void.self) { group in
      // Enqueue more
      for i in 50..<100 {
        group.addTask {
          queue.enqueue(i)
        }
      }

      // Dequeue some
      for _ in 0..<30 {
        group.addTask {
          _ = queue.dequeue()
        }
      }
    }

    #expect(queue.count == 70)
  }
}
