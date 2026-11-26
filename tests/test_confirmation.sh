#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/services.sh"

# y, Y, and Enter should confirm the action.
for answer in y Y ""; do
    if printf '%s\n' "$answer" | confirm_service_action "start" "demo.service" >/dev/null; then
        :
    else
        echo "Expected answer '$answer' to confirm." >&2
        exit 1
    fi
done

# Any other response should cancel the action.
for answer in n N no cancel; do
    if printf '%s\n' "$answer" | confirm_service_action "stop" "demo.service" >/dev/null; then
        echo "Expected answer '$answer' to cancel." >&2
        exit 1
    fi
done

echo "Confirmation prompt tests passed."
