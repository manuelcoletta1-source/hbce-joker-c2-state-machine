# HBCE — JOKER-C2 State Machine

Deterministic execution model for Joker-C2.

This repository defines the canonical state machine governing:

- Execution states
- Transition rules
- Guard conditions
- Fail-closed behavior
- Evidence requirements

This repo contains no private keys and no runtime secrets.

It serves as the formal specification layer between:

- `hbce-joker-c2-core` (execution engine)
- `hbce-joker-c2-registry` (root-of-trust and cryptographic anchoring)

---

## Core Principles

- Deterministic transitions
- Append-only evidence
- Fail-closed by default
- Explicit ALLOW / DENY states
- Cryptographic verifiability

---

## Contents

- `machine/machine.json` — states, events, transitions
- `machine/guards.md` — normative guard conditions (fail-closed)
- `machine/evidence_contract.json` — minimum evidence fields contract
- `docs/links.md` — spec ↔ core ↔ registry map
- `tools/verify-genesis.sh` — verifies GENESIS sha256 + signature

---

## Quickstart: Verify Registry GENESIS

Clone the registry repo next to this repo, then run:

```bash
bash tools/verify-genesis.sh ../hbce-joker-c2-registry

Expected output includes:

PASS: sha256 match

PASS: signature valid


If any check fails, treat the registry as invalid (fail-closed).


---

HBCE — HERMETICUM B.C.E. S.r.l.

---

