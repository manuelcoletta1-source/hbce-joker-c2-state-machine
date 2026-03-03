# Joker-C2 Revocation & Key Rotation Model (HBCE)

Goal: define how Joker-C2 signing keys are revoked and rotated without breaking auditability.
Posture: fail-closed. If revocation status cannot be proven => treat signatures as invalid.

This document is normative for operational readiness.

---

## 1. Definitions

- **Signing key**: Ed25519 key pair used by Joker-C2 to sign evidence.
- **Active key**: currently valid signer for new evidence.
- **Revoked key**: signer that MUST NOT be accepted for new evidence after revocation time.
- **Key set**: ordered list of keys with validity windows.

---

## 2. Core rules (fail-closed)

- R0: Verifiers MUST accept evidence only if the signing key is valid for the evidence timestamp.
- R1: If key status cannot be determined, evidence MUST be rejected (DENY).
- R2: Key rotation MUST be published in the public registry before evidence is produced with the new key.
- R3: Revocation is append-only: never delete or rewrite previous key records.

---

## 3. Public registry artifacts (in `hbce-joker-c2-registry`)

### 3.1 Key directory
`registry/keys/`

Contains one folder per key id, or flat files if minimal.

Minimum published files per key:

- `joker-c2_public.pem`
- `joker-c2_public.sha256`

Recommended additional metadata:

- `key-meta.json` (id, created_at, status)
- `key-meta.sig` (signed by registry authority / current key)

### 3.2 Revocation list
`registry/keys/revocations.json`

Append-only list of revocation records.

Each record MUST include:
- `key_sha256`
- `revoked_at` (ISO8601)
- `reason` (short string)
- `replaced_by` (new key fingerprint or null)
- `record_hash` (sha256 of canonical record)
- `sig` (Ed25519 signature by registry authority)

Fail-closed rule:
- if `revocations.json` is missing => treat as unknown => reject in strict mode.

### 3.3 Key set manifest (recommended)
`registry/keys/keyset.json`

Defines validity windows.

Fields:
- `active_key_sha256`
- `keys[]`: each with `key_sha256`, `valid_from`, `valid_to|null`, `status`

---

## 4. Rotation procedure (operational)

### Step 1 — Generate new key pair (offline if possible)
- Create new Ed25519 keypair.
- Compute and record public key sha256 fingerprint.

### Step 2 — Publish new public key to registry
- Add `joker-c2_public.pem` (new) and fingerprint file.
- Update `keyset.json` to include the new key with `valid_from`.
- Commit and push registry.

### Step 3 — Activate new key in CORE
- Deploy new private key to the signing environment.
- CORE MUST reference the `active_key_sha256` used to sign evidence.

### Step 4 — Revoke old key (if compromise or planned deprecation)
- Append a revocation record in `revocations.json`.
- Update `keyset.json` to close `valid_to` for old key.
- Commit and push registry.

---

## 5. Evidence binding requirements

Every evidence entry MUST bind to a key identifier:

Minimum:
- `sig.alg` = `ed25519`
- `sig.by` = `JOKER-C2`
- `sig.key_sha256` = sha256 of the public key PEM (fingerprint)
- `ts.end` (or signing timestamp)

Verifier rules:
- Verify signature with the public key matching `sig.key_sha256`.
- Check key validity window for `ts.end`.
- If revoked before `ts.end` => reject.

---

## 6. Compromise scenarios

### Scenario A — Private key leak
Action:
- Immediate revocation record appended (`revoked_at` = incident time).
- New key published and activated.
Expected verifier behavior:
- Evidence after `revoked_at` signed by old key => invalid.

### Scenario B — Registry tampering attempt
Action:
- GENESIS verification fails, or signatures mismatch.
Expected behavior:
- Treat registry as invalid => reject all evidence (fail-closed).

---

## 7. Minimal compliance (audit checklist)

- [ ] Registry publishes public key + sha256 fingerprint
- [ ] Evidence binds to `sig.key_sha256`
- [ ] Registry publishes revocations list (append-only)
- [ ] Registry publishes key set with validity windows
- [ ] Rotation procedure documented and reproducible
- [ ] Verifier rejects unknown or unverifiable key status

---

HBCE — HERMETICUM B.C.E. S.r.l.
