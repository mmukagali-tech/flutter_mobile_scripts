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
Build IPA for the specified flavor.

    -h                Display help
    -f FLAVOR         Flavor of the build (development, production)
EOF
}

# Parse command-line arguments
while getopts "hf:" opt; do
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
  echo "Missing required arguments." 1>&2
  usage
  exit 1
fi

if [[ ! -f "$APP_CONFIG" ]]; then
  log_error "Missing $APP_CONFIG file. 💔"
  exit 1
fi

log_info "Building iOS... 🍏"
fvm flutter build ipa \
    --release \
    --obfuscate \
    --split-debug-info="$IPA_FLUTTER_SYMBOLS" \
    --export-options-plist="$EXPORT_OPTIONS_PLIST" \
    --dart-define BUILD_TYPE="$flavor" \
    --dart-define-from-file "$APP_CONFIG" || {
        log_error "Failed to build iOS. 💔"
        exit 1
    }
log_success "iOS build complete. 🎯"