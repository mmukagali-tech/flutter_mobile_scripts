#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


usage() {
    echo "Usage: $0 --apc-api-key-id <App Store Connect API Key ID> --apc-api-issuer-id <App Store Connect API Issuer ID> --apc-api-key-file <App Store Connect API Key File>"
    echo "  --apc-api-key-id      App Store Connect API Key ID"
    echo "  --apc-api-issuer-id   App Store Connect API Issuer ID"
    echo "  --apc-api-key-file    App Store Connect API Key File"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --apc-api-key-id) apc_api_key_id="$2"; shift ;;
        --apc-api-issuer-id) apc_api_issuer_id="$2"; shift ;;
        --apc-api-key-file) apc_api_key_file="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Check if required arguments are provided
if [[ -z "$apc_api_key_id" || -z "$apc_api_issuer_id" || -z "$apc_api_key_file" ]]; then
    usage
fi



log_info "Deploying to TestFlight... 🚀"

log_info "Getting ipa file path..."
# Read the first line of the file
first_line=$(head -n 1 $PROJECT_ROOT/artifacts/ios/builds/metadata.dat)

# Split the line into components using ',' as the delimiter
IFS=',' read -r version build job ipaPath <<< "$first_line"

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
cd $PROJECT_ROOT/ios/ && bundle exec fastlane tf_deploy api_key_id:${apc_api_key_id} api_issuer_id:${apc_api_issuer_id} api_key_file:"$PROJECT_ROOT/${apc_api_key_file}" ipa:${ipaPath} || {
    log_error "Failed to deploy to TestFlight. 💔"
    exit 1
}

log_success "Deployed to TestFlight. 🚀"