#!/usr/bin/env bash
set -euo pipefail

REGISTRY_DIR="${1:-../hbce-joker-c2-registry}"

GENESIS_JSON="${REGISTRY_DIR}/registry/genesis/GENESIS.json"
GENESIS_SHA="${REGISTRY_DIR}/registry/genesis/GENESIS.sha256"
GENESIS_SIG_B64="${REGISTRY_DIR}/registry/genesis/GENESIS.sig"
PUBKEY_PEM="${REGISTRY_DIR}/registry/keys/joker-c2_public.pem"

echo "[1/3] Checking files..."
test -f "${GENESIS_JSON}"
test -f "${GENESIS_SHA}"
test -f "${GENESIS_SIG_B64}"
test -f "${PUBKEY_PEM}"

echo "[2/3] Verifying sha256..."
EXPECTED="$(cat "${GENESIS_SHA}" | tr -d '[:space:]')"
ACTUAL="$(sha256sum "${GENESIS_JSON}" | awk '{print $1}')"

if [ "${EXPECTED}" != "${ACTUAL}" ]; then
  echo "FAIL: sha256 mismatch"
  echo " expected: ${EXPECTED}"
  echo " actual:   ${ACTUAL}"
  exit 2
fi
echo "PASS: sha256 match"

echo "[3/3] Verifying ed25519 signature..."
SIG_BIN="$(mktemp)"
trap 'rm -f "${SIG_BIN}"' EXIT

cat "${GENESIS_SIG_B64}" | tr -d '[:space:]' | base64 -d > "${SIG_BIN}"

# OpenSSL verify for Ed25519:
# pkeyutl -verify expects the signature file via -sigfile
openssl pkeyutl -verify -pubin -inkey "${PUBKEY_PEM}" -rawin -in "${GENESIS_JSON}" -sigfile "${SIG_BIN}" >/dev/null

echo "PASS: signature valid"
