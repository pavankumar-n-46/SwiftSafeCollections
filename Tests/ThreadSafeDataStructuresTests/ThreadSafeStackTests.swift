import Testing

@testable import ThreadSafeDataStructures

// MARK: - Basic Operations Tests

@Suite("ThreadSafeStack Basic Operations")
struct ThreadSafeStackBasicTests {

  @Test("Initialize empty stack")
  func testInitializeEmpty() {
    let stack = ThreadSafeStack<Int>()
    #expect(stack.isEmpty)
    #expect(stack.count == 0)
  }

  @Test("Push elements")
  func testPush() {
    let stack = ThreadSafeStack<String>()

    stack.push("first")
    stack.push("second")
    stack.push("third")

    #expect(stack.count == 3)
    #expect(!stack.isEmpty)
  }

  @Test("Pop elements (LIFO)")
  func testPop() {
    let stack = ThreadSafeStack<Int>()
    stack.push(1)
    stack.push(2)
    stack.push(3)

    #expect(stack.pop() == 3)
    #expect(stack.pop() == 2)
    #expect(stack.pop() == 1)
    #expect(stack.isEmpty)
  }

  @Test("Pop from empty stack")
  func testPopEmpty() {
    let stack = ThreadSafeStack<Int>()

    #expect(stack.pop() == nil)
  }

  @Test("Peek top element")
  func testPeek() {
    let stack = ThreadSafeStack<String>()
    stack.push("first")
    stack.push("second")

    #expect(stack.peek() == "second")
    #expect(stack.count == 2)  // Peek doesn't remove
  }

  @Test("Remove all elements")
  func testRemoveAll() {
    let stack = ThreadSafeStack<Int>()
    stack.push(1)
    stack.push(2)
    stack.push(3)

    stack.removeAll()

    #expect(stack.isEmpty)
    #expect(stack.count == 0)
  }
}

// MARK: - Concurrency Tests

@Suite("ThreadSafeStack Concurrency")
struct ThreadSafeStackConcurrencyTests {

  @Test("Concurrent pushes")
  func testConcurrentPushes() async {
    let stack = ThreadSafeStack<Int>()

    await withTaskGroup(of: Void.self) { group in
      for i in 0..<100 {
        group.addTask {
          stack.push(i)
        }
      }
    }

    #expect(stack.count == 100)
  }

  @Test("Concurrent pushes and pops")
  func testConcurrentPushPop() async {
    let stack = ThreadSafeStack<Int>()

    // Pre-populate
    for i in 0..<50 {
      stack.push(i)
    }

    await withTaskGroup(of: Void.self) { group in
      // Push more
      for i in 50..<100 {
        group.addTask {
          stack.push(i)
        }
      }

      // Pop some
      for _ in 0..<30 {
        group.addTask {
          _ = stack.pop()
        }
      }
    }

    #expect(stack.count == 70)
  }
}
