# SwiftSafeCollections

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS%20%7C%20Linux-blue.svg)](https://swift.org)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-86%20passing-success.svg)](Tests/)

A production-ready Swift package providing **thread-safe data structures** with configurable locking strategies. Built with Test-Driven Development (TDD) and Protocol-Oriented Programming (POP).

## ✨ Features

- 🔒 **Thread-Safe**: All operations are atomic and concurrency-safe
- ⚡ **High Performance**: Optimized read-write locks for concurrent reads
- 🎯 **Protocol-Oriented**: Clean, composable architecture
- 🧪 **Fully Tested**: 86 comprehensive tests with 100% coverage
- 📦 **Zero Dependencies**: Pure Swift implementation
- 🌍 **Cross-Platform**: iOS, macOS, tvOS, watchOS, visionOS, and Linux
- 🚀 **Swift 6 Ready**: Strict concurrency compliant

## 📦 Data Structures

| Structure | Description | Use Case |
|-----------|-------------|----------|
| `ThreadSafeArray<Element>` | Thread-safe array with subscript access | General-purpose ordered collection |
| `ThreadSafeDictionary<Key, Value>` | Thread-safe key-value storage | Caching, configuration management |
| `ThreadSafeSet<Element>` | Thread-safe unique elements | Deduplication, membership testing |
| `ThreadSafeQueue<Element>` | FIFO queue | Task queues, message passing |
| `ThreadSafeStack<Element>` | LIFO stack | Undo/redo, parsing |
| `ThreadSafeDeque<Element>` | Double-ended queue | Sliding windows, breadth-first search |

## 🚀 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/pavankumar-n-46/SwiftSafeCollections", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/pavankumar-n-46/SwiftSafeCollections`
3. Select version and add to your target

## 💡 Quick Start

### ThreadSafeArray

```swift
import ThreadSafeDataStructures

let array = ThreadSafeArray<Int>()

// Thread-safe operations
array.append(1)
array.append(2)
array.append(3)

print(array[0])  // Optional(1)
print(array.count)  // 3

// Functional operations
let doubled = array.map { $0 * 2 }  // [2, 4, 6]
```

### ThreadSafeDictionary

```swift
let cache = ThreadSafeDictionary<String, Data>()

// Labeled subscript for value access
cache[key: "user123"] = userData
let data = cache[key: "user123"]

// Traditional dictionary operations
cache.updateValue(newData, forKey: "user123")
cache.removeValue(forKey: "user123")

// Atomic snapshot
let snapshot = cache.snapshot()
```

### ThreadSafeSet

```swift
let userIds = ThreadSafeSet<String>()

// Set operations
userIds.insert("user1")
userIds.insert("user2")

// Set algebra
let set1: ThreadSafeSet<Int> = [1, 2, 3]
let set2: ThreadSafeSet<Int> = [3, 4, 5]

let union = set1.union(set2)  // [1, 2, 3, 4, 5]
let intersection = set1.intersection(set2)  // [3]
```

### ThreadSafeQueue (FIFO)

```swift
let queue = ThreadSafeQueue<String>()

queue.enqueue("first")
queue.enqueue("second")
queue.enqueue("third")

print(queue.dequeue())  // Optional("first")
print(queue.peek())     // Optional("second")
```

### ThreadSafeStack (LIFO)

```swift
let stack = ThreadSafeStack<Int>()

stack.push(1)
stack.push(2)
stack.push(3)

print(stack.pop())   // Optional(3)
print(stack.peek())  // Optional(2)
```

### ThreadSafeDeque

```swift
let deque = ThreadSafeDeque<Int>()

deque.appendBack(1)
deque.appendFront(0)
deque.appendBack(2)

print(deque.removeFront())  // Optional(0)
print(deque.removeBack())   // Optional(2)
```

## 🔧 Advanced Usage

### Custom Locking Strategies

All data structures support configurable locking strategies:

```swift
// Read-Write Lock (default - optimized for read-heavy workloads)
let array1 = ThreadSafeArray<Int>(lock: ReadWriteLock())

// Mutex Lock (simple exclusive locking)
let array2 = ThreadSafeArray<Int>(lock: MutexLock())

// Dispatch Queue Lock (GCD-based)
let array3 = ThreadSafeArray<Int>(lock: DispatchQueueLock())
```

### Concurrent Operations

```swift
let cache = ThreadSafeDictionary<String, Data>()

await withTaskGroup(of: Void.self) { group in
    for i in 0..<1000 {
        group.addTask {
            cache[key: "key\(i)"] = Data()
        }
    }
}

print(cache.count)  // 1000
```

### Functional Programming

```swift
let numbers = ThreadSafeArray<Int>()
(1...100).forEach { numbers.append($0) }

// Map, filter, reduce
let evens = numbers.filter { $0 % 2 == 0 }
let doubled = numbers.map { $0 * 2 }

// ForEach with side effects
var sum = 0
numbers.forEach { sum += $0 }
```

## 🏗️ Architecture

### Design Patterns

- **Decorator Pattern**: Thread-safe wrappers around Swift collections
- **Strategy Pattern**: Configurable locking mechanisms
- **Protocol-Oriented Design**: Composable protocol hierarchy

### Protocol Hierarchy

```
ThreadSafeCollection (base protocol)
    ├── count: Int
    ├── isEmpty: Bool
    └── removeAll()

ThreadSafeSequence: ThreadSafeCollection
    ├── forEach(_:)
    ├── map(_:)
    └── filter(_:)

ThreadSafeSubscriptable: ThreadSafeCollection
    └── subscript(index:) -> Element?
```

### Locking Strategies

| Strategy | Implementation | Best For |
|----------|---------------|----------|
| `ReadWriteLock` | pthread_rwlock_t | Read-heavy workloads |
| `MutexLock` | pthread_mutex_t | Balanced read/write |
| `DispatchQueueLock` | DispatchQueue + barrier | GCD integration |

## 🧪 Testing

The package includes **86 comprehensive tests** covering:

- ✅ Basic operations (CRUD)
- ✅ Edge cases (empty, nil, bounds)
- ✅ Functional operations (map, filter, forEach)
- ✅ Concurrency scenarios (race conditions, deadlocks)
- ✅ Set algebra operations
- ✅ FIFO/LIFO behavior

Run tests:

```bash
swift test
```

## 📊 Performance

Optimized for production use:

- **Concurrent Reads**: Multiple threads can read simultaneously
- **Exclusive Writes**: Barrier-based writes ensure data integrity
- **Lock-Free Snapshots**: Atomic copy-on-read for consistency
- **O(1) Operations**: Where possible (append, peek, etc.)

## 🔒 Thread Safety Guarantees

All operations are:
- ✅ **Atomic**: Operations complete without interruption
- ✅ **Isolated**: No data races or race conditions
- ✅ **Consistent**: Snapshots provide point-in-time views
- ✅ **Sendable**: Swift 6 concurrency compliant

## 📚 Documentation

Full API documentation is available in the source code. Each type includes:
- Comprehensive doc comments
- Usage examples
- Thread-safety guarantees
- Performance characteristics

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`swift test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with:
- Swift 6.0
- Swift Testing framework
- Protocol-Oriented Programming principles
- Test-Driven Development methodology

## 📞 Support

- 🐛 [Report a bug](https://github.com/pavankumar-n-46/SwiftSafeCollections/issues)
- � [Request a feature](https://github.com/pavankumar-n-46/SwiftSafeCollections/issues)
- � [Read the docs](https://github.com/pavankumar-n-46/SwiftSafeCollections/wiki)

---

**Made with ❤️ for the Swift community**
