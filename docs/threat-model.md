# Joker-C2 Threat Model (HBCE)

Scope: Joker-C2 triad (CORE + REGISTRY + STATE-MACHINE) used for accountable execution.
Goal: define adversaries, assets, trust boundaries, attack surfaces, and required mitigations.
Posture: EU-first, audit-first, fail-closed, append-only evidence.

This document is normative for operational readiness.

---

## 1. Assets (what must be protected)

### A1 — Private signing key (Ed25519)
The Joker-C2 private key used to sign evidence.
If compromised, an attacker can forge valid-looking evidence.

### A2 — Registry GENESIS
Root-of-trust material anchoring:
- GENESIS.json
- GENESIS.sha256
- GENESIS.sig
- Published public key and fingerprint

### A3 — Evidence ledger (append-only)
Evidence entries (json/jsonl) and their chain integrity.

### A4 — Policy packs
Rules that determine ALLOW/DENY outcomes.

### A5 — Deterministic state machine specification
States/events/guards/contracts that define valid execution.

---

## 2. Security goals (what must always be true)

- G0 Fail-closed: missing proof => DENY.
- G1 Authenticity: evidence MUST be attributable to a known signer.
- G2 Integrity: evidence MUST be tamper-evident (hash-chained).
- G3 Non-repudiation (practical): signer cannot plausibly deny signing valid entries.
- G4 Auditability: third parties can verify decisions offline.
- G5 Least authority: execution scope is bounded and explicit.

---

## 3. Trust boundaries

### TB1 — Signing environment (CORE host)
Where the private key exists. This boundary is assumed high risk.

### TB2 — Public registry (REGISTRY repo)
Public materials only. No secrets. Must remain verifiable.

### TB3 — Verifiers (public/offline)
Any party validating GENESIS and evidence with public keys.

### TB4 — Policy authoring and publication
Who can author and approve policy packs; how they are distributed.

---

## 4. Adversaries

### ADV1 — External attacker
No privileged access. Attempts tampering, replay, and supply-chain attacks.

### ADV2 — Malicious operator (insider)
Has access to CORE runtime or filesystem. Attempts to forge or delete evidence.

### ADV3 — Compromised dependency / supply chain
NPM/Node or system tooling compromised to alter signing/verifying behavior.

### ADV4 — Repo-level attacker
Can submit PRs or attempt to alter registry/spec content.

---

## 5. Attack surfaces

- S1 Key storage and handling (files, env vars, backups)
- S2 Evidence generation pipeline (canonicalization, hashing, signing)
- S3 Ledger write path (append-only enforcement)
- S4 Verification tooling (scripts, parsers)
- S5 Policy distribution (version downgrade, substitution)
- S6 Build system and dependencies (lockfiles, integrity)

---

## 6. Primary threats and required mitigations

### T1 — Private key compromise (A1)
Impact: attacker can forge signatures.
Required mitigations:
- Store keys outside repos; never commit secrets.
- Prefer offline or hardware-backed storage when available.
- Key rotation mechanism (revocation + new key publish) MUST exist.
- Evidence MUST include `sig.by` and key fingerprint binding.

### T2 — Ledger tampering / deletion (A3)
Impact: audit breaks, history rewritten.
Required mitigations:
- Append-only semantics enforced by tooling (deny rewrite).
- Each entry includes `prev_entry_hash` + `entry_hash`.
- Periodic anchoring (optional): hash checkpoints to external timestamping.

### T3 — Replay attacks (evidence re-used)
Impact: old ALLOW reused as new ALLOW.
Required mitigations:
- `request_id` uniqueness enforced.
- Include timestamps and input hash binding.
- Verifier rejects duplicates and time-inconsistent entries.

### T4 — Policy downgrade / substitution (A4)
Impact: attacker replaces policy pack to permit actions.
Required mitigations:
- Policy packs MUST be content-addressed (sha256).
- Policy pack version and hash MUST be included in evidence.
- Allow lists MUST be explicit; missing rule => DENY.

### T5 — Verification tool compromise (S4)
Impact: false PASS shown to users.
Required mitigations:
- Verifiers MUST be minimal and reproducible.
- Cross-verification: independent implementations encouraged.
- Scripts should fail hard on parsing ambiguity.

### T6 — Spec / state machine drift (A5)
Impact: CORE behavior diverges from normative spec.
Required mitigations:
- Spec version MUST be referenced by CORE (v/id hash).
- CI checks should compare expected fields and transitions.
- Undefined transitions MUST map to DENY.

### T7 — Supply-chain attacks (ADV3)
Impact: compromised libs alter behavior silently.
Required mitigations:
- Lock dependencies (lockfile committed).
- Prefer minimal dependency surface for verification.
- Deterministic build notes and integrity checks.

---

## 7. Residual risk (explicitly accepted)

- If the signing host is fully compromised, attacker may sign valid evidence until key is rotated.
- Human governance (policy authoring) remains a sociotechnical risk; mitigate with multi-party review.

---

## 8. Operational readiness checklist (minimum)

- [ ] Registry GENESIS is verifiable (sha256 + Ed25519 signature)
- [ ] Public key fingerprint is published
- [ ] Evidence contract is enforced (minimum fields)
- [ ] Key rotation + revocation model exists
- [ ] Policy packs are content-addressed and referenced in evidence
- [ ] Deterministic verification works offline
- [ ] Dependency lockfiles and reproducible build notes exist

---

HBCE — HERMETICUM B.C.E. S.r.l.
