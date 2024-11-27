#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Checking temporary keychain $TEMP_KEYCHAIN... 🔍"

if [[ ! -f "$HOME/Library/Keychains/$TEMP_KEYCHAIN" ]]; then
  log_error "Keychain $TEMP_KEYCHAIN does not exist. 🚫"
  exit 1
fi

if [[ $(security list-keychain -d user) != *"$TEMP_KEYCHAIN"* ]]; then
  log_error "Keychain $TEMP_KEYCHAIN is not active. 🚫"
  log_info "Run temp_keychain_delete.sh then temp_keychain_create.sh to recreate the keychain."
  exit 1
fi

log_success "Temporary keychain is active. 🎯"
