#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
cat <<EOF
Usage: ${0##*/} [-hbaei]
Clean build files.

    -h                Display help
    -b                Clean build files
    -a                Clean artifacts
    -e                Clean secure files (.secure_files/)
    -i                Clean sign files (key.properties, ExportOptions.plist)
EOF
}

clean_build=0
clean_artifacts=0
clean_secure_files=0
clean_sign_files=0

# Parse command-line arguments
while getopts "hbaei" opt; do
    case $opt in
    h)
        usage
        exit 0
        ;;
    b)
        clean_build=1
        ;;
    a)
        clean_artifacts=1
        ;;
    e)
        clean_secure_files=1
        ;;
    i)
        clean_sign_files=1
        ;;
    \?)
        echo "Invalid option: $OPTARG" 1>&2
        usage
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." 1>&2
        usage
        exit 1
        ;;
    esac
done


log_info "Cleaning project... 🧹"

if [[ $clean_build -eq 1 ]]; then
    log_info "Cleaning build... 🧹"
    rm -rf "$PROJECT_ROOT/build" || {
        log_error "Failed to clean build. 💔"
        exit 1
    }
    log_success "Build cleaned. 🧹"
fi

if [[ $clean_artifacts -eq 1 ]]; then
    log_info "Cleaning artifacts... 🧹"
    rm -rf "$ARTIFACTS" || {
        log_error "Failed to clean artifacts. 💔"
        exit 1
    }
    log_success "Artifacts cleaned. 🧹"
fi

if [[ $clean_secure_files -eq 1 ]]; then
    log_info "Cleaning secure files... 🧹"
    rm -rf "$SECURE_FILES" || {
        log_error "Failed to clean secure files. 💔"
        exit 1
    }
    log_success "Secure files cleaned. 🧹"
fi

if [[ $clean_sign_files -eq 1 ]]; then
    log_info "Cleaning sign files... 🧹"
    rm -f "$ANDROID_KEY_PROPERTIES" || {
        log_error "Failed to clean key.properties. 💔"
        exit 1
    }
    rm -f "$EXPORT_OPTIONS_PLIST" || {
        log_error "Failed to clean ExportOptions.plist. 💔"
        exit 1
    }
    log_success "Sign files cleaned. 🧹"
fi

log_success "Project cleaned. 🧹"