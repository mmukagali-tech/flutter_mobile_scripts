#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || {
    echo "Missing variables.sh"
    exit 1
}
[[ -f "scripts/logger.sh" ]] || {
    echo "Missing logger.sh"
    exit 1
}

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
cat <<EOF
Usage: ${0##*/} [-hfigF]
Get project dependencies.

    -h                Display help
    -f                Get Flutter dependencies
    -i                Get iOS dependencies
    -g                Get Gems dependencies
    -F                Force fetching dependencies (ignores checks)
EOF
}

get_flutter=0
get_ios=0
get_gems=0
force=0

# Parse command-line arguments
while getopts "hfigF" opt; do
    case $opt in
    h)
        usage
        exit 0
        ;;
    f)
        get_flutter=1
        ;;
    i)
        get_ios=1
        ;;
    g)
        get_gems=1
        ;;
    F)
        force=1
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

if [[ $get_flutter -eq 1 || $force -eq 1 ]]; then
    log_info "Getting Flutter dependencies... 📦"
    fvm flutter pub get
    log_success "Flutter dependencies fetched. ✅"
fi

if [[ $get_ios -eq 1 || $force -eq 1 ]]; then
    log_info "Getting iOS dependencies... 📦"
    export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    cd ios
    bundle exec pod install --repo-update || {
        log_error "Failed to install pods. ❌"
        exit 1
    }
    cd ..
    log_success "iOS dependencies fetched. ✅"
fi

if [[ $get_gems -eq 1 || $force -eq 1 ]]; then
    export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    if ! command -v bundle > /dev/null; then
        log_warning "Bundler not found. Installing... 🔧"
        gem install bundler || {
            log_error "Failed to install bundler. ❌"
            exit 1
        }
        log_success "Bundler installed. 🎯"
    fi

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
fi

log_success "Dependencies fetched and installed. ✅"
