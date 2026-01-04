#!/usr/bin/env bash

# TOTP Service Switcher - Switch to next service directly
# Uses shared TOTP library for common functionality

set -euo pipefail

# Load TOTP common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/totp-common.sh"

# Validate configuration
if ! validate_totp_config; then
    notify-send "TOTP" "Configuration file not found or empty" -u critical
    exit 1
fi

# Switch to next service
next_index=$(switch_to_next_service)
if [[ -z "$next_index" ]]; then
    notify-send "TOTP" "Failed to switch to next service" -u critical
    exit 1
fi

# Get new service info
service_info=$(get_service_info "$next_index")
if [[ -z "$service_info" ]]; then
    notify-send "TOTP" "Invalid service configuration" -u critical
    exit 1
fi

service_name=$(echo "$service_info" | cut -d':' -f1)
secret_key=$(echo "$service_info" | cut -d':' -f2)

# Generate TOTP code for new service
totp_code=$(generate_totp_code "$secret_key")
case $? in
    0)
        # Success - show notification and refresh waybar
        remaining=$(get_totp_remaining_time)
        notify-send "TOTP" "Switched to: $service_name\nCode: $totp_code\nRemaining: ${remaining}s" -t 3000
        refresh_waybar
        ;;
    2)
        notify-send "TOTP" "Please install oath-toolkit: sudo pacman -S oath-toolkit" -u critical
        ;;
    3)
        notify-send "TOTP" "Invalid TOTP key format for $service_name" -u critical
        ;;
    *)
        notify-send "TOTP" "Failed to generate TOTP code for $service_name" -u critical
        ;;
esac