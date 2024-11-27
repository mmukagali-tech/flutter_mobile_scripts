#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Cleaning build... 🧹"
rm -rf "$PROJECT_ROOT/build" || {
    log_error "Failed to clean build. 💔"
    exit 1
}

rm -rf "$PROJECT_ROOT/artifacts" || {
    log_error "Failed to clean artifacts. 💔"
    exit 1
}

log_success "Build cleaned. 🧹"