#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


usage() {
cat <<EOF
Usage: ${0##*/} [-h] [-p PACKAGE_NAME] [NAME] [-j API_JSON_KEY] [FILE]
Deploy to Play Store.

    -h                Display help
    -p PACKAGE_NAME   Package name
    -j API_JSON_KEY   Play Store API JSON file
EOF
}

package_name=""
api_json_key=""

# Parse command-line arguments
while getopts "hp:j:" opt; do
    case $opt in
    h)
        usage
        exit 0
        ;;
    p)
        package_name=$OPTARG
        ;;
    j)
        api_json_key=$OPTARG
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
if [[ -z "$package_name" || -z "$api_json_key" ]]; then
    echo "Missing required arguments" 1>&2
    usage
    exit 1
fi

api_json_key="$PROJECT_ROOT/$api_json_key"

# Check if the file exists
[[ -f "$api_json_key" ]] || { log_error "File not found: $api_json_key"; exit 1; }


log_info "Deploying to Play Store... 🚀"

log_info "Getting aab file path..."
# Read the first line of the file
first_line=$(head -n 1 "$PROJECT_ROOT"/artifacts/android/builds/metadata.dat)

# Split the line into components using ',' as the delimiter
IFS=',' read -r _ _ _ aabPath <<< "$first_line"

if [[ -z "$aabPath" ]]; then
    log_error "Failed to get aab file path. 💔"
    exit 1
fi
if [[ ! -f "$aabPath" ]]; then
    log_error "AAB file not found at path: $aabPath. 💔"
    exit 1
fi
log_warning "Make sure is correct aab file"
echo "AAB file path: $aabPath"


export PATH="$HOME/.rbenv/shims:$HOME/.rbevn/bin:$PATH"
eval "$(rbenv init -)"

log_info "Deploying to Play Store using fastlane... 🚀"
cd "$PROJECT_ROOT"/android/

bundle exec fastlane upload_to_playstore package_name:"${package_name}" aab:"${aabPath}" json_key:"${api_json_key}" || {
    log_error "Failed to deploy to Play Store. 💔"
    exit 1
}
cd ..

log_info "Successfully deployed to Play Store. 🎉"