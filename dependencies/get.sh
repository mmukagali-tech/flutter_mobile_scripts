#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"



log_info "Getting dependencies... 📦"
fvm flutter pub get
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
cd ios && bundle exec pod install --repo-update || {
    log_error "Failed to install pods. ❌"
    exit 1
}
cd ..
log_success "Dependencies fetched and installed. ✅"