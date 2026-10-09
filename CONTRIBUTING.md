# Contributing to Pulse

Thank you for your interest in contributing to Pulse! We welcome contributions
from the community and appreciate your time and effort.

---

## Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) `>=3.5.0`
- [Flutter SDK](https://docs.flutter.dev/get-started/install) — the exact version is
  pinned in `.fvmrc` (CI reads the same file). We recommend [FVM](https://fvm.app/):
  ```bash
  fvm install   # installs the version pinned in .fvmrc
  ```
- [Melos](https://melos.invertase.dev/) 8+ (config lives in the root `pubspec.yaml`) — install via:
  ```bash
  dart pub global activate melos
  ```

### Setup

```bash
# Clone the repository
git clone https://github.com/alamin-karno/pulse.git
cd pulse

# Bootstrap the monorepo (installs dependencies and links packages)
melos bootstrap
```

> **Using FVM?** Run melos through `fvm exec` so it and every `dart`/`flutter` command
> it spawns use the pinned SDK instead of whatever is on your `PATH`:
> `fvm exec dart run melos bootstrap`, `fvm exec dart run melos run check`, etc.
> Point your IDE's Flutter SDK path at `.fvm/flutter_sdk`.

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
# Pure Dart tests (pulse_dev)
melos run test

# Flutter tests (pulse_dev_flutter)
melos run test:flutter
```

### Validate publishability

```bash
melos run publish:dry
```

---

## Contribution Types

### Bug Reports

- Use [GitHub Issues](https://github.com/alamin-karno/pulse/issues)
- Include: Dart/Flutter version, minimal reproduction, expected vs actual behavior
- Label: `bug`

### Feature Requests

- Open a [GitHub Issue](https://github.com/alamin-karno/pulse/issues) with label
  `enhancement` — for significant new features, describe the proposal there before
  writing code

### Pull Requests

1. Fork the repository
2. Branch off `dev`: `git checkout dev && git checkout -b feature/my-feature`
   (or `bugfix/…`, `docs/…`, `chore/…`, `ci/…` — see [Branching model](#branching-model))
3. Make your changes
4. Ensure all checks pass: `melos run check`
5. Update `CHANGELOG.md` under `## Unreleased`
6. Add or update documentation comments for any public API changes
7. Submit a PR against **`dev`** (not `main`) — `dev` is the default branch, so GitHub
   targets it automatically

---

## Branching model

Pulse uses [git flow](https://nvie.com/posts/a-successful-git-branching-model/).
`main` and `dev` are protected: no direct pushes, no deletion — everything lands via a
pull request with passing CI.

**`dev` is the repository's default branch.** It holds the latest integrated (possibly
unreleased) work: clones check it out, and new pull requests target it by default.
`main` only moves on a release or hotfix and always matches what's published on
pub.dev — check out `main` (or a release tag) if you need the released code.

| Branch               | Branches from | Merges into              | Merge method |
|----------------------|---------------|--------------------------|--------------|
| `feature/*`, `bugfix/*`, `docs/*`, `chore/*`, `ci/*`, `refactor/*`, `test/*` | `dev` | `dev` | Squash |
| `release/x.y.z`      | `dev`         | `main`                   | Merge commit |
| `hotfix/*`           | `main`        | `main`                   | Merge commit |
| `main` (back-merge)  | —             | `dev`                    | Merge commit |

The `Branch policy` check enforces these source → target rules. Release and back-merge
PRs use merge commits (not squash) so `main` and `dev` keep a shared history.

### Releasing (maintainers)

1. Cut `release/x.y.z` from `dev`.
2. On the release branch: bump `version:` in each changed package's `pubspec.yaml`, and
   rename every `## Unreleased` changelog heading (root + packages) to the version.
   The `Branch policy` check rejects a release PR that still has an `Unreleased` section.
3. Run `melos run check` and `melos run publish:dry`, then open a PR into `main` —
   change the PR's base from the default `dev` to `main`
   (`gh pr create --base main`).
4. After it merges, tag `main` once per released package — `<package>-v<version>`, e.g.
   `pulse_dev-v0.1.1` — and push the tags. Each tag publishes that package to pub.dev
   via the `Publish to pub.dev` workflow (OIDC, no stored secrets). Create a GitHub
   Release for the release.
5. Open a PR from `main` into `dev` to back-merge the release.

### What CI runs, and when

| Workflow          | Trigger                                        | Runs                                                        |
|-------------------|------------------------------------------------|-------------------------------------------------------------|
| `CI`              | PR into `dev`/`main`; push to `dev`/`main`     | Format, analyze, test (all packages), publish dry-run       |
| `Branch Policy`   | PR into `dev`/`main`                           | Source → target branch rules; finalized changelogs for `main` |
| `Publish to pub.dev` | Push of a `<package>-v<version>` tag        | Verifies tag is on `main` and matches pubspec + changelog, dry-run, publish |
| `Validate Packages` | Weekly (Mon 08:00 UTC), manual               | Publish dry-run of every package (catches SDK/pub drift)    |

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

- `pulse_dev` must remain Flutter-free — do not import `package:flutter` or `dart:ui`
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
