#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

log_info "Setting up Flutter... 🚀"

log_info "Checking FVM..."
if ! command -v fvm >/dev/null; then
    log_warning "FVM not found. Installing... 🔧"
    brew tap leoafarias/fvm;
    brew install fvm && log_success "FVM installed."
else 
    log_success "FVM found."
fi

log_info "Checking Flutter $PROJECT_FLUTTER_VERSION..."
if ! fvm list | grep -q $PROJECT_FLUTTER_VERSION; then
    log_warning "Flutter $PROJECT_FLUTTER_VERSION not found. Installing... ⏳"
    fvm install "$PROJECT_FLUTTER_VERSION" || {
        log_error "Failed to install Flutter $PROJECT_FLUTTER_VERSION. Exiting... 🚫"
        exit 1
    }
    log_success "Flutter $PROJECT_FLUTTER_VERSION installed."
else
    log_success "Flutter $PROJECT_FLUTTER_VERSION found."
fi

fvm use $PROJECT_FLUTTER_VERSION

fvm_output=$(fvm use)
current_flutter_version=$(echo "$fvm_output" | awk -F '[\\[\\]]' '{print $2}')

if [[ "$current_flutter_version" == $PROJECT_FLUTTER_VERSION ]]; then
    log_success "Flutter version is correct. 🎉"
else
    log_error "Flutter version is incorrect. Exiting... 🚫"
    exit 1
fi

log_success "Flutter setup complete. 🎯"