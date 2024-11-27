#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Cleaning cache... 🗑️"
fvm flutter clean || {
    log_error "Failed to clean project. ❌"
    exit 1
}
rm -rf ios/Pods ios/Podfile.lock
dart pub cache clean || {
    log_error "Failed to clean Dart cache. ❌"
    exit 1
}
log_success "Cache cleaned. ✨"