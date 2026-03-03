# Joker-C2 Guards (Fail-Closed)

This document defines mandatory guard conditions for state transitions.
Guards are normative: if a guard cannot be proven, the transition MUST be denied.

---

## Global Guards

- **G0 — Determinism:** the same input + same policy + same registry context MUST produce the same decision.
- **G1 — Fail-closed:** missing/unknown rule == DENY.
- **G2 — Evidence required:** every request MUST produce an evidence record (ALLOW or DENY).
- **G3 — No secrets in evidence:** evidence is hash-only/public-safe by default.

---

## Transition Guards

### INIT → REQUEST_RECEIVED (REQUEST_SUBMITTED)
Required proof:
- `request_id` exists and is well-formed
- `ipr_subject` exists (or request is rejected)

### REQUEST_RECEIVED → POLICY_EVALUATION (POLICY_PASS)
Required proof:
- policy document resolved
- policy evaluation result == PASS

### REQUEST_RECEIVED → EXECUTION_DENIED (POLICY_DENY)
Required proof:
- policy evaluation result == DENY
Outcome:
- execution MUST NOT run
- evidence MUST be recorded

### POLICY_EVALUATION → EXECUTION_ALLOWED (GATE_ALLOW)
Required proof:
- gate decision == ALLOW
- operator constraints satisfied (if applicable)

### POLICY_EVALUATION → EXECUTION_DENIED (GATE_DENY)
Required proof:
- gate decision == DENY

### EXECUTION_ALLOWED → EXECUTION_COMPLETED (EXEC_OK)
Required proof:
- execution completed successfully
- tool trace available

### EXECUTION_ALLOWED → ERROR (EXEC_FAIL)
Required proof:
- execution failed
- error summary captured (no secrets)

### EXECUTION_DENIED → EVIDENCE_RECORDED (EVIDENCE_COMMITTED)
Required proof:
- evidence entry appended
- signature present (ed25519)

### EXECUTION_COMPLETED → EVIDENCE_RECORDED (EVIDENCE_COMMITTED)
Required proof:
- evidence entry appended
- signature present (ed25519)

### ERROR → ROLLBACK (ROLLBACK_OK / ROLLBACK_FAIL)
Required proof:
- rollback attempt recorded
- evidence entry appended

---

## Mandatory Evidence Fields (minimum)

- `v`
- `request_id`
- `ipr_subject`
- `policy.result` (PASS/DENY)
- `gate.result` (ALLOW/DENY)
- `hashes.input_hash`
- `chain.prev_entry_hash`
- `chain.entry_hash`
- `sig.alg` = `ed25519`
- `sig.by` = `JOKER-C2`

---

HBCE — HERMETICUM B.C.E. S.r.l.
