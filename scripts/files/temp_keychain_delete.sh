#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


# Check if keychain is not exists
if [[ ! -f "$HOME/Library/Keychains/$TEMP_KEYCHAIN" ]]; then
  log_info "Keychain $TEMP_KEYCHAIN does not exist. 💔"
  security list-keychain -d user
  exit 0
fi

log_info "Deleting temporary keychain $TEMP_KEYCHAIN... 🗑️"

security delete-keychain "$TEMP_KEYCHAIN" || {
  echo "Failed to delete the temporary keychain file."
  exit 1
}

log_success "Keychain deleted successfully. 🚀"

log_info "Listing keychains... 🔑"
security list-keychain -d user