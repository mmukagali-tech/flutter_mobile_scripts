#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
cat <<EOF
Usage: ${0##*/} [-h] [-k API_KEY_ID] [ID] [-i API_ISSUER_ID] [ID] [-f API_KEY_FILE] [FILE]
Deploy to TestFlight.

    -h                Display help
    -k API_KEY_ID     App Store Connect API Key ID
    -i API_ISSUER_ID  App Store Connect API Issuer ID
    -f API_KEY_FILE   App Store Connect API Key File
EOF
}

api_key_id=""
api_issuer_id=""
api_key_file=""

# Parse command-line arguments
while getopts "hk:i:f:" opt; do
    case $opt in
    h)
        usage
        exit 0
        ;;
    k)
        api_key_id=$OPTARG
        ;;
    i)
        api_issuer_id=$OPTARG
        ;;
    f)
        api_key_file=$OPTARG
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
if [[ -z "$api_key_id" || -z "$api_issuer_id" || -z "$api_key_file" ]]; then
    echo "Missing required arguments" 1>&2
    usage
    exit 1
fi


log_info "Deploying to TestFlight... 🚀"

log_info "Getting ipa file path..."
# Read the first line of the file
first_line=$(head -n 1 "$PROJECT_ROOT"/artifacts/ios/builds/metadata.dat)

# Split the line into components using ',' as the delimiter
IFS=',' read -r _ _ _ ipaPath <<< "$first_line"

if [[ -z "$ipaPath" ]]; then
    log_error "Failed to get ipa file path. 💔"
    exit 1
fi
if [[ ! -f "$ipaPath" ]]; then
    log_error "IPA file not found at path: $ipaPath. 💔"
    exit 1
fi
log_warning "Make sure is correct ipa file"
echo "IPA file path: $ipaPath"


export PATH="$HOME/.rbenv/shims:$HOME/.rbevn/bin:$PATH"
eval "$(rbenv init -)"

log_info "Deploying to TestFlight using fastlane... 🚀"
cd "$PROJECT_ROOT"/ios/
bundle exec fastlane tf_deploy api_key_id:"${api_key_id}" api_issuer_id:"${api_issuer_id}" api_key_file:"$PROJECT_ROOT/${api_key_file}" ipa:"${ipaPath}" || {
    log_error "Failed to deploy to TestFlight. 💔"
    exit 1
}
cd ..

log_success "Deployed to TestFlight. 🚀"