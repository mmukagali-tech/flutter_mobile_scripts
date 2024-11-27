#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Incrementing build number... 🚀"

export PATH="$HOME/.rbenv/shims:$HOME/.rbevn/bin:$PATH"
eval "$(rbenv init -)"

cd $PROJECT_ROOT/ && bundle exec fastlane increment_build || {
    log_error "Failed to increment build number. 💔"
    exit 1
}

log_success "Build number incremented. 🚀"