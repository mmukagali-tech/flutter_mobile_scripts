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

log_info "Building App Bundle... 📦"
fvm flutter build appbundle \
    --release \
    --obfuscate \
    --split-debug-info=$AAB_FLUTTER_SYMBOLS \
    --dart-define BUILD_TYPE=$flavor \
    --dart-define-from-file config/configs.json || {
        log_error "Failed to build App Bundle. 💔"
        exit 1
    }
log_success "App Bundle build complete. 🎯"