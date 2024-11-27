#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"



log_info "Cleaning up project... 🧹"
fvm flutter clean || {
    log_error "Failed to clean project. ❌"
    exit 1
}
log_success "Clean complete. 🧼"