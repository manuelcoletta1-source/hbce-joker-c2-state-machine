# Joker-C2 — Spec ↔ Core ↔ Registry

This repo defines the normative state machine.

## Repositories

- **CORE (execution engine):** `hbce-joker-c2-core`
  - Implements the state machine
  - Produces evidence entries (jsonl)
  - Uses Ed25519 signing locally

- **REGISTRY (root-of-trust):** `hbce-joker-c2-registry`
  - Publishes public keys
  - Anchors GENESIS (sha256)
  - Publishes GENESIS signature
  - Append-only posture (public-safe)

- **STATE MACHINE (this repo):** `hbce-joker-c2-state-machine`
  - Canonical states/events/transitions
  - Guard conditions (fail-closed)
  - Evidence contract (minimum fields)

## Integration Rule

- CORE MUST conform to STATE-MACHINE.
- REGISTRY MUST anchor the root signer used by CORE.
- Any mismatch MUST be treated as DENY (fail-closed).

---

HBCE — HERMETICUM B.C.E. S.r.l.
