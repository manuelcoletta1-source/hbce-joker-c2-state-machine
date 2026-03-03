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

## Canonical High-Level States

- `INIT`
- `REQUEST_RECEIVED`
- `POLICY_EVALUATION`
- `GATE_DECISION`
- `EXECUTION_ALLOWED`
- `EXECUTION_DENIED`
- `EXECUTION_COMPLETED`
- `EVIDENCE_RECORDED`
- `ERROR`
- `ROLLBACK`

The state machine is normative.
Implementations must conform.

---

HBCE — HERMETICUM B.C.E. S.r.l.
