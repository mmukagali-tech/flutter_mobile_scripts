#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
  echo "Usage: $0 -f <flavor>"
  echo "  -f  Flavor of the build (development, production)"
  exit 1
}

# Parse command-line arguments
while getopts "f:" opt; do
  case $opt in
    f) flavor="$OPTARG" ;;
    *) usage ;;
  esac
done

# Check if required arguments are provided
if [[ -z "$flavor" ]]; then
  usage
fi

log_info "Building iOS... 🍏"
fvm flutter build ipa \
    --release \
    --obfuscate \
    --split-debug-info=$IPA_FLUTTER_SYMBOLS \
    --export-options-plist=$EXPORT_OPTIONS_PLIST \
    --dart-define BUILD_TYPE=$flavor \
    --dart-define-from-file config/configs.json || {
        log_error "Failed to build iOS. 💔"
        exit 1
    }
log_success "iOS build complete. 🎯"