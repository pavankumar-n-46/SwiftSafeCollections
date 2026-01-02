# Contributing to ThreadSafeDataStructures

Thank you for your interest in contributing! 🎉

## How to Contribute

### Reporting Bugs 🐛

1. Check if the bug has already been reported in [Issues](https://github.com/yourusername/ThreadSafeDataStructures/issues)
2. If not, create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Swift version and platform
   - Code sample if applicable

### Suggesting Features 💡

1. Check existing [Issues](https://github.com/yourusername/ThreadSafeDataStructures/issues) and [Discussions](https://github.com/yourusername/ThreadSafeDataStructures/discussions)
2. Create a new issue describing:
   - The problem you're trying to solve
   - Your proposed solution
   - Alternative approaches considered
   - Example usage

### Pull Requests 🔧

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes** following our guidelines:
   - Write tests first (TDD approach)
   - Follow Swift API Design Guidelines
   - Add documentation comments
   - Ensure thread safety

4. **Run tests**:
   ```bash
   swift test
   ```

5. **Commit** with clear messages:
   ```bash
   git commit -m "Add feature: description"
   ```

6. **Push** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request** with:
   - Description of changes
   - Related issue number
   - Test coverage
   - Breaking changes (if any)

## Development Guidelines

### Code Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Keep functions focused and concise
- Add doc comments for public APIs

### Testing Requirements

- Write tests before implementation (TDD)
- Aim for 100% code coverage
- Include:
  - Basic operation tests
  - Edge case tests
  - Concurrency tests
  - Performance tests (if applicable)

### Documentation

- Add doc comments to all public APIs
- Include usage examples
- Document thread-safety guarantees
- Note performance characteristics

### Thread Safety

- All public methods must be thread-safe
- Use appropriate locking strategies
- Test concurrent access scenarios
- Document any blocking operations

## Project Structure

```
ThreadSafeDataStructures/
├── Sources/
│   └── ThreadSafeDataStructures/
│       ├── Protocols/          # Protocol definitions
│       └── DataStructures/     # Implementations
├── Tests/
│   └── ThreadSafeDataStructuresTests/
└── .github/
    └── workflows/              # CI/CD
```

## Questions?

- 💬 [Start a Discussion](https://github.com/yourusername/ThreadSafeDataStructures/discussions)
- 📧 Email: your.email@example.com
- 🐦 Twitter: [@yourhandle](https://twitter.com/yourhandle)

## Code of Conduct

Be respectful, inclusive, and constructive. We're all here to learn and build great software together! 🤝

---

**Thank you for contributing!** ❤️
