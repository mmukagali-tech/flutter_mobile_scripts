#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
cat << EOF
Usage: ${0##*/} [-hc]
Run tests.
    -h                Display help
    -c                CI mode
EOF
}

ci_mode=0

# Parse command-line arguments
while getopts "hc" opt; do
  case $opt in
    h)
        usage
        exit 0
        ;;
    c)
        ci_mode=1
        ;;
    \?)
        echo "Invalid option: $OPTARG" 1>&2
        usage
        exit 1
        ;;
    :)
        echo "Invalid option: $OPTARG requires an argument" 1>&2
        usage
        exit 1
        ;;
  esac
done

if [[ $ci_mode -eq 0 ]]; then
    log_info "Running tests... 🧪"
    fvm flutter test || {
        log_error "Failed to run tests. 💔"
        exit 1
    }
    log_success "Tests complete. 🎉"
    exit 0
fi

log_info "Running tests for CI... 🧪"
fvm flutter test --machine > test_report.json || {
    log_error "Failed to run tests. 💔"
    exit 1
}
log_success "Tests complete. 📋"