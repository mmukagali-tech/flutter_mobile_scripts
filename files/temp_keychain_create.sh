#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


if [[ $(security list-keychain -d user) == *"$TEMP_KEYCHAIN"* ]]; then
    log_info "Keychain is already created. 🔑"
    exit 0
fi

log_info "Creating temporary keychain $TEMP_KEYCHAIN... 🔐"

security create-keychain -p "$TEMP_KEYCHAIN_PASSWORD" "$TEMP_KEYCHAIN"
security set-keychain-settings -l -u -t 21600 "$TEMP_KEYCHAIN"
security unlock-keychain -p "$TEMP_KEYCHAIN_PASSWORD" "$TEMP_KEYCHAIN"

security list-keychain -d user -s "$TEMP_KEYCHAIN" $(security list-keychain -d user | tr -d '"' | tr '\n' ' ') || {
    log_error "Failed to activate the keychain. 🚫"
    exit 1
}

log_success "Temporary keychain created successfully. 🚀"

log_info "Listing keychains... 🔑"
security list-keychain -d user