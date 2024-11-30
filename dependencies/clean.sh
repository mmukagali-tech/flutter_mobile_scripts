#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
cat << EOF
Usage: ${0##*/} [-hficlg]
Clean the project.

    -h                Display help
    -f                Clean Flutter
    -i                Clean iOS
    -c                Clean cache
    -l                Clean lock files
    -g                Clean gems
EOF
}

clean_flutter=0
clean_ios=0
clean_cache=0
clean_lock=0
clean_gems=0

# Parse command-line arguments
while getopts "hficlg" opt; do
  case $opt in
    h)
        usage
        exit 0
        ;;
    f)
        clean_flutter=1
        ;;
    i)
        clean_ios=1
        ;;
    c)
        clean_cache=1
        ;;
    l)
        clean_lock=1
        ;;
    g)
        clean_gems=1
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



log_info "Cleaning up project... 🧹"

if [[ $clean_flutter -eq 1 ]]; then
    log_info "Cleaning Flutter... 🦋"
    fvm flutter clean || {
        log_error "Failed to clean Flutter project. ❌"
        exit 1
    }
    log_success "Flutter clean complete. 🦋"
fi

if [[ $clean_ios -eq 1 ]]; then
    log_info "Cleaning iOS... 🍏"
    rm -rf ios/Pods ios/Podfile.lock
    log_success "iOS clean complete. 🍏"
fi

if [[ $clean_cache -eq 1 ]]; then
    log_info "Cleaning cache... 🗑️"
    dart pub cache clean || {
        log_error "Failed to clean Dart cache. ❌"
        exit 1
    }
    log_success "Cache clean complete. ✨"
fi

if [[ $clean_lock -eq 1 ]]; then
    log_info "Cleaning lock files... 🔒"
    rm -rf pubspec.lock
    log_success "Lock files clean complete. 🔒"
fi

if [[ $clean_gems -eq 1 ]]; then
    log_info "Cleaning gems... 💎"
    rm -rf vendor/bundle
    log_success "Gems clean complete. 💎"
fi

log_success "Clean complete. 🧼"