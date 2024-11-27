#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Generating code... 🧬"
dart run build_runner build --delete-conflicting-outputs || {
    log_error "Failed to generate code. 💔"
    exit 1
}

log_success "Code generated. 🧬"