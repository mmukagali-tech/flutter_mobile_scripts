#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


usage() {
cat <<EOF
Usage: ${0##*/} [-h] [-f FLAVOR] [development|production]
Setup configuration files.

    -h                Display help
    -f FLAVOR         Set the flavor (development|production) 
EOF
}

flavor=""

# Parse command-line arguments
while getopts "hf:" opt; do
    case $opt in
    h)
        usage
        exit 0
        ;;
    f)
        flavor=$OPTARG
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

if [[ -z "$flavor" ]]; then
    echo "Missing flavor argument" 1>&2
    usage
    exit 1
fi

if [[ "$flavor" != "development" && "$flavor" != "production" ]]; then
    echo "Invalid flavor argument" 1>&2
    usage
    exit 1
fi

log_info "Setting up configuration files... 🚀"

if [[ "$flavor" == "development" ]]; then
    if [[ ! -f "$DEV_CONFIG" ]]; then
        log_error "Development configuration file not found: $DEV_CONFIG"
        exit 1
    fi
    cp -f "$DEV_CONFIG" "$CONFIG"
elif [[ "$flavor" == "production" ]]; then
    if [[ ! -f "$PROD_CONFIG" ]]; then
        log_error "Production configuration file not found: $PROD_CONFIG"
        exit 1
    fi
    cp -f "$PROD_CONFIG" "$CONFIG"
fi

log_success "Configuration files setup complete! 🎉"