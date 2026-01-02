# v1.1.0 Release Notes

## Release Title
🔒 Critical Fix: Add Sendable Constraints for True Thread Safety

## Release Type
**BREAKING CHANGE** - Minor version bump (1.0.0 → 1.1.0)

## Summary

This release fixes a critical thread safety issue identified by the community. While locks protected collection storage, they didn't prevent element mutations from causing data races. We've added `Sendable` constraints to all generic type parameters to ensure complete thread safety.

## 🐛 Bug Fix

### Issue
Locks protected collection access but not element mutations. This could cause data races:

```swift
// ❌ Previously allowed but unsafe
class Person {
    var name: String  // Mutable!
}

let array = ThreadSafeArray<Person>()
array.append(Person(name: "Alice"))

// Data race! Two threads mutating the same object
Task { array[0]?.name = "Bob" }
Task { print(array[0]?.name) }
```

### Solution
Added `Sendable` constraints to all data structures:

- `ThreadSafeArray<Element>` → `where Element: Sendable`
- `ThreadSafeDictionary<Key, Value>` → `where Key: Sendable, Value: Sendable`
- `ThreadSafeSet<Element>` → `where Element: Sendable`
- `ThreadSafeQueue<Element>` → `where Element: Sendable`
- `ThreadSafeStack<Element>` → `where Element: Sendable`
- `ThreadSafeDeque<Element>` → `where Element: Sendable`

## ⚠️ Breaking Changes

Non-`Sendable` types will no longer compile:

```swift
// ❌ No longer compiles (good!)
class UnsafeClass { var value: Int }
let array = ThreadSafeArray<UnsafeClass>()  // Compile error

// ✅ Works - use Sendable types
struct SafeStruct: Sendable { let value: Int }
let array = ThreadSafeArray<SafeStruct>()  // ✅

// ✅ Works - most Swift types are Sendable
let numbers = ThreadSafeArray<Int>()  // ✅
let names = ThreadSafeArray<String>()  // ✅
```

## 📊 Migration Guide

Most users won't need to change anything - standard Swift types (`Int`, `String`, `Data`, etc.) are already `Sendable`.

If you're using custom types:

**Before:**
```swift
struct User {
    let id: String
    let name: String
}
let users = ThreadSafeArray<User>()
```

**After:**
```swift
struct User: Sendable {  // Add conformance
    let id: String
    let name: String
}
let users = ThreadSafeArray<User>()
```

## ✅ Verification

- All 86 tests passing
- No regressions
- Correct compile-time enforcement

## 🙏 Acknowledgments

Special thanks to the Reddit community for identifying this issue! This is exactly the kind of feedback that makes open source great.

## 📚 Documentation

Updated README with:
- Sendable requirement explanation
- Clear examples of what works and what doesn't
- Rationale for the design decision

## 📦 Installation

```swift
dependencies: [
    .package(url: "https://github.com/pavankumar-n-46/SwiftSafeCollections", from: "1.1.0")
]
```

---

**Community feedback makes this package better. Thank you!** ❤️
