#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
cat << EOF
Usage: ${0##*/} [-h] [-s STOREPASSWORD] [PASSWORD] [-k KEYPASSWORD] [PASSWORD] [-a KEYALIAS] [ALIAS]
Create key.properties file for signing the APK.

    -h                Display help
    -s STOREPASSWORD  Password for the keystore
    -k KEYPASSWORD    Password for the key
    -a KEYALIAS       Alias of the key
EOF
}

storePassword=""
keyPassword=""
keyAlias=""

while getopts "s:k:a:h:" opt; do
    case ${opt} in
        h)
            usage
            exit 0
            ;;
        s)
            storePassword=$OPTARG
            ;;
        k)
            keyPassword=$OPTARG
            ;;
        a)
            keyAlias=$OPTARG
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
if [[ -z "$storePassword" || -z "$keyPassword" || -z "$keyAlias" ]]; then
    echo "Missing required arguments" 1>&2
    usage
    exit 1
fi

if [[ -z "$ANDROID_KEY_PROPERTIES" ]]; then
    log_error "ANDROID_KEY_PROPERTIES is not set in variables.sh. 🛑"
    exit 1
fi

log_info "Creating key.properties... 🔑"
rm -f "$ANDROID_KEY_PROPERTIES"
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