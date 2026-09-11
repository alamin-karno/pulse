# Workspace Rules

Full project rules, architecture constraints, and phase status live in `CLAUDE.md` and
`docs/architecture.md` / `docs/ROADMAP.md` at the repo root — read those first. This file
is a short pointer for agent tools that don't load `CLAUDE.md` automatically; don't fork
detailed rules here, keep it in sync by reference only.

- Before pushing any code, always run the CI checks locally: `melos run check` (format,
  analyze, analyze:flutter, test, test:flutter — see `melos.yaml`).
- When implementing a new feature, update the `CHANGELOG.md`, `README.md`, and any other
  related documentation files to reflect the changes, in every package touched.
- Cloud/backend work (ingestion API, dashboard, feature flags) is intentionally deferred
  — see `docs/ROADMAP.md`. Don't start it without an explicit go-ahead.
