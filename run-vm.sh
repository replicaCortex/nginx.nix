#!/usr/bin/env bash

set -euo pipefail

frontend_disk=$(mktemp -p "${TMPDIR:-/tmp}" "nixos-frontend.XXXXXX.qcow2")
backend_disk=$(mktemp -p "${TMPDIR:-/tmp}" "nixos-backend.XXXXXX.qcow2")
export NIX_DISK_IMAGE_FRONTEND=$frontend_disk
export NIX_DISK_IMAGE_BACKEND=$backend_disk

cleanup() {
    pkill -P $$ || true
    rm -f "$NIX_DISK_IMAGE_FRONTEND" "$NIX_DISK_IMAGE_BACKEND"
    echo "clear"
}
trap cleanup EXIT

"$FRONTEND_VM"/bin/run-nixos-vm >frontend.log  2>&1 &
FRONTEND_PID=$!

"$BACKEND_VM"/bin/run-nixos-vm >backend.log  2>&1 &
BACKEND_PID=$!

echo "Frontend PID: $FRONTEND_PID, port 8080"
echo "Backend PID: $BACKEND_PID, port 8081"

wait "$FRONTEND_PID" "$BACKEND_PID"
