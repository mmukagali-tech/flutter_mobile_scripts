#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Setting up helper environment... 🛠️"

log_info "Checking yq..."
if ! command -v yq > /dev/null; then 
    log_warning "yq not found. Installing... 🔧"
    brew install yq && log_success "yq installed."
else 
    log_success "yq found."
fi

log_success "Helper environment setup complete. 🎯"