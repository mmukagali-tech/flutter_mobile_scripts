#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
  echo "Usage: $0 --storePassword <storePassword> --keyPassword <keyPassword> --keyAlias <keyAlias>"
  echo "  --storePassword  Password for the keystore"
  echo "  --keyPassword    Password for the key"
  echo "  --keyAlias       Alias of the key"
  exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --storePassword)
        storePassword="$2"
        shift 2
        ;;
        --keyPassword)
        keyPassword="$2"
        shift 2
        ;;
        --keyAlias)
        keyAlias="$2"
        shift 2
        ;;
        *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
done

# Check if required arguments are provided
if [[ -z "$storePassword" || -z "$keyPassword" || -z "$keyAlias" ]]; then
  usage
fi

if [[ -z "$ANDROID_KEY_PROPERTIES" ]]; then
    log_error "ANDROID_KEY_PROPERTIES is not set in variables.sh. 🛑"
    exit 1
fi

log_info "Creating key.properties... 🔑"
rm -f $ANDROID_KEY_PROPERTIES
{
    echo "storePassword=$storePassword"
    echo "keyPassword=$keyPassword"
    echo "keyAlias=$keyAlias"
    echo "storeFile=$UPLOAD_KEYSTORE"
} > "$ANDROID_KEY_PROPERTIES" || {
    log_error "Failed to create key.properties. 🚫"
    exit 1
}

log_success "key.properties created. 🔏"