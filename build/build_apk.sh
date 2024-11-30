#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
cat << EOF
Usage: ${0##*/} [-h] [-f FLAVOR] [development, production]
Build APK for the specified flavor.

    -h                Display help
    -f FLAVOR         Flavor of the build (development, production)
EOF
}

# Parse command-line arguments
while getopts "f:" opt; do
  case $opt in
    h)
        usage
        exit 0
        ;;
    f)
        flavor="$OPTARG"
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

# Check if required arguments are provided
if [[ -z "$flavor" ]]; then
  usage
  exit 1
fi

log_info "Building APK... 📱"
fvm flutter build apk \
    --release \
    --obfuscate \
    --split-debug-info=$APK_FLUTTER_SYMBOLS \
    --dart-define BUILD_TYPE=$flavor \
    --dart-define-from-file config/configs.json || {
        log_error "Failed to build APK. 💔"
        exit 1
    }
log_success "APK build complete. 🎯"