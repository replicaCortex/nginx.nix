#!/usr/bin/env bash

set -euo pipefail

frontend_disk=$(mktemp -p "${TMPDIR:-/tmp}" "nixos-frontend.XXXXXX.qcow2")
backend_disk=$(mktemp -p "${TMPDIR:-/tmp}" "nixos-backend.XXXXXX.qcow2")
export NIX_DISK_IMAGE_FRONTEND=$frontend_disk
export NIX_DISK_IMAGE_BACKEND=$backend_disk

# Очистка при завершении
cleanup() {
    echo "Останавливаем QEMU..."
    pkill -P $$ || true
    rm -f "$NIX_DISK_IMAGE_FRONTEND" "$NIX_DISK_IMAGE_BACKEND"
    echo "Очистка завершена."
}
trap cleanup EXIT

echo "Запуск frontend..."
"$FRONTEND_VM"/bin/run-nixos-vm >frontend.log  2>&1 &
FRONTEND_PID=$!

echo "Запуск backend..."
"$BACKEND_VM"/bin/run-nixos-vm >backend.log  2>&1 &
BACKEND_PID=$!

echo "Frontend PID: $FRONTEND_PID"
echo "Backend PID: $BACKEND_PID"
echo "Логи: ./frontend.log и ./backend.log"

wait "$FRONTEND_PID" "$BACKEND_PID"
