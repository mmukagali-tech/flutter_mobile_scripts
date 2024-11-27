#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Setting local Ruby version to $PROJECT_RUBY_VERSION..."
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
rbenv local $PROJECT_RUBY_VERSION
rbenv rehash

log_info "Installing bundler... 💎"
gem install bundler || {
    log_error "Failed to install bundler. ❌"
    exit 1
}
log_success "Bundler installed. 🎯"

log_info "Installing Ruby gems for root dir... 💎"
bundle config set path 'vendor/bundle'
bundle install || {
    log_error "Failed to install gems. ❌"
    exit 1
}
log_success "Gems installed. 🎯"

log_info "Installing Ruby gems for Android... 💎"
cd android
bundle config set path '../vendor/bundle'
bundle install || {
    log_error "Failed to install gems. ❌"
    exit 1
}
cd ..
log_success "Gems installed for Android. 🎯"

log_info "Installing Ruby gems for iOS... 💎"
cd ios
bundle config set path '../vendor/bundle'
bundle install || {
    log_error "Failed to install gems. ❌"
    exit 1
}
cd ..
log_success "Gems installed for iOS. 🎯"