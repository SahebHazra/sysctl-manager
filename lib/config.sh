#!/usr/bin/env bash
# lib/config.sh - Global configurations for sysman

# Record file to track services stopped by this script
RECORD_FILE="$HOME/.stopped_by_script.txt"

# Ensure record file exists
init_config() {
    touch "$RECORD_FILE"
}