#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Setting up Ruby... 💎"

log_info "Checking Homebrew..."
if ! command -v brew > /dev/null; then 
    log_error "Homebrew not found. Exiting... 🚫"
    exit 1
else 
    log_success "Homebrew found."
fi

log_info "Checking rbenv..."
if ! command -v rbenv > /dev/null; then 
    log_warning "rbenv not found. Installing... 🔧"
    brew install rbenv && log_success "rbenv installed."
else 
    log_success "rbenv found."
fi

echo "Checking ruby-build..."
if ! command -v ruby-build > /dev/null; then 
    log_warning "ruby-build not found. Installing... 🔧"
    brew install ruby-build && log_success "ruby-build installed."
else 
    log_success "ruby-build found."
fi

echo "Checking rbenv $PROJECT_RUBY_VERSION version..."
if ! rbenv versions | grep -q $PROJECT_RUBY_VERSION; then 
    log_warning "Ruby $PROJECT_RUBY_VERSION not found. Installing... ⏳"
    rbenv install "$PROJECT_RUBY_VERSION" || {
        log_error "Failed to install Ruby $PROJECT_RUBY_VERSION. Exiting... 🚫"
        exit 1
    }
    log_success "Ruby $PROJECT_RUBY_VERSION installed."
else 
    log_success "Ruby $PROJECT_RUBY_VERSION found."
fi

log_info "Setting global Ruby version to $PROJECT_RUBY_VERSION..."
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
rbenv local $PROJECT_RUBY_VERSION
rbenv rehash

current_ruby_version=$(ruby -v | awk '{print $2}')

if [[ "$current_ruby_version" == "$PROJECT_RUBY_VERSION" ]]; then
    log_success "Ruby version is correct. 🎉"
else
    log_error "Ruby version is incorrect $current_ruby_version. Exiting... 🚫"
    exit 1
fi

log_success "Ruby setup complete. 🎯"