#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Uploading dSYMs... 📦"

dsymPath=$(find "$PROJECT_ROOT/artifacts/ios/dsyms" -name "*.dSYM" | head -1)

if [[ -z "$dsymPath" ]]; then
    log_error "dSYM not found. 💔"
    exit 1
fi

ls -d -- ios/Pods/*

"$PROJECT_ROOT/ios/Pods/FirebaseCrashlytics/upload-symbols" -gsp ios/Runner/GoogleService-Info.plist -p ios "$dsymPath" || {
    log_error "Failed to upload dSYMs. 💔"
    exit 1
}

log_success "dSYMs uploaded. 🚀"