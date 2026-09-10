# Contributing to Pulse

Thank you for your interest in contributing to Pulse! We welcome contributions
from the community and appreciate your time and effort.

---

## Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) `>=3.5.0`
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- [Melos](https://melos.invertase.dev/) — install via:
  ```bash
  dart pub global activate melos
  ```

### Setup

```bash
# Clone the repository
git clone https://github.com/pulse-dart/pulse.git
cd pulse

# Bootstrap the monorepo (installs dependencies and links packages)
melos bootstrap
```

### Verify your setup

```bash
melos run check
```

This runs formatting, analysis, and all tests. All checks must pass before
submitting a PR.

---

## Development Workflow

### Run formatting

```bash
melos run format
```

### Run static analysis

```bash
melos run analyze
```

### Run tests

```bash
# Pure Dart tests (pulse_core)
melos run test

# Flutter tests (pulse_flutter)
melos run test:flutter
```

### Validate publishability

```bash
melos run publish:dry
```

---

## Contribution Types

### Bug Reports

- Use [GitHub Issues](https://github.com/pulse-dart/pulse/issues)
- Include: Dart/Flutter version, minimal reproduction, expected vs actual behavior
- Label: `bug`

### Feature Requests

- Open a [GitHub Discussion](https://github.com/pulse-dart/pulse/discussions) first
  for significant new features
- For small additions, open an issue with label `enhancement`

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Make your changes
4. Ensure all checks pass: `melos run check`
5. Update `CHANGELOG.md` under `## Unreleased`
6. Add or update documentation comments for any public API changes
7. Submit a PR against `main`

### Documentation

Documentation improvements are always welcome. The main docs are:
- [`README.md`](README.md) — project overview
- [`docs/architecture.md`](docs/architecture.md) — architecture reference
- Inline documentation comments in source files

---

## Code Standards

### Dart style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `dart format` before committing
- All analyzer warnings must be resolved

### Documentation

- Every public API must have a documentation comment (`///`)
- Use `{@template}` / `{@macro}` for shared doc content where appropriate
- Include usage examples in documentation comments for non-trivial APIs

### Testing

- Every documented behavior must have a test
- Tests must be deterministic (use `FakeClock`, `FakeIdGenerator`)
- No mocking frameworks — write hand-rolled test doubles
- Tests should be fast and isolated (no network, no filesystem)

### Architecture

- `pulse_core` must remain Flutter-free — do not import `package:flutter` or `dart:ui`
- All interfaces must have documentation explaining the contract
- All implementations must honor their interface contracts

---

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(core): add network event type
fix(flutter): preserve original FlutterError handler
docs: update quick start example
test(core): add sanitizer edge case tests
chore: bump melos to 6.x
```

---

## Changelog

Every PR that changes behavior must update `CHANGELOG.md` under `## Unreleased`.
Follow the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

---

## License

By contributing to Pulse, you agree that your contributions will be licensed
under the [MIT License](LICENSE).
