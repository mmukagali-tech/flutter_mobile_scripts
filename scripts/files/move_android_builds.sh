#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


usage() {
cat <<EOF
Usage: ${0##*/} [-h] [-f FLAVOR] [development, production]
Move Android prod builds.

    -h                Display help
    -f FLAVOR         Flavor of the build (development, production)
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

# Check if required arguments are provided
if [[ -z "$flavor" ]]; then
    echo "Missing required arguments" 1>&2
    usage
    exit 1
fi


log_info "Moving Android prod builds... 📦"

export PATH="$HOME/.rbenv/shims:$HOME/.rbevn/bin:$PATH"
eval "$(rbenv init -)"

cd "$PROJECT_ROOT"/android/
bundle exec fastlane move_files flavor:"${flavor}" || {
    log_error "Failed to move Android prod builds. 💔"
    exit 1
}
cd "$PROJECT_ROOT"

log_success "Android prod builds moved. 🚀"