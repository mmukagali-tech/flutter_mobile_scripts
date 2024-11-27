#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Running tests for CI... 🧪"
fvm flutter test --machine > test_report.json || {
    log_error "Failed to run tests. 💔"
    exit 1
}
log_success "Tests complete. 📋"