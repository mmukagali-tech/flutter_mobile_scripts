#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
  echo "Usage: $0 [patch|minor|major|custom:<version>]"
  exit 1
}

# Ensure an argument is provided
if [[ $# -ne 1 ]]; then
    echo "Invalid number of arguments"
    usage
fi


log_info "Incrementing app version... 🚀"

export PATH="$HOME/.rbenv/shims:$HOME/.rbevn/bin:$PATH"
eval "$(rbenv init -)"

cd "$PROJECT_ROOT"
bundle exec fastlane increment_version type:"$1" || {
    log_error "Failed to increment app version. 💔"
    exit 1
}

log_success "App version incremented. 🚀"
