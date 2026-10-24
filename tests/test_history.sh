#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

RECORD_FILE="$TEMP_DIR/history.txt"
source "$ROOT_DIR/lib/services.sh"

# A stopped service is recorded once, even if the operation is repeated.
record_stopped_service "demo.service"
record_stopped_service "demo.service"
record_stopped_service "other.service"

[[ "$(wc -l < "$RECORD_FILE")" -eq 2 ]]
grep -qxF "demo.service" "$RECORD_FILE"
grep -qxF "other.service" "$RECORD_FILE"

# Removing one service preserves other history entries.
remove_stopped_service "demo.service"
[[ "$(wc -l < "$RECORD_FILE")" -eq 1 ]]
! grep -qxF "demo.service" "$RECORD_FILE"
grep -qxF "other.service" "$RECORD_FILE"

# Removing an absent service is safe and leaves the file unchanged.
remove_stopped_service "missing.service"
grep -qxF "other.service" "$RECORD_FILE"

echo "History helper tests passed."
