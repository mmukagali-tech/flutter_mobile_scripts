#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
  echo "Usage: $0 -g <googleServiceAccountKey> -b <buildType> -a <appId>"
  echo "  -g  Path to the Google service account key"
  echo "  -b  Build type (apk, aab, ipa)"
  echo "  -a  Firebase app ID"
  exit 1
}

# Parse command-line arguments
while getopts "g:b:a:" opt; do
  case $opt in
    g) googleServiceAccountKey="$OPTARG" ;;
    b) buildType="$OPTARG" ;;
    a) appId="$OPTARG" ;;
    *) usage ;;
  esac
done

if [[ -z "$googleServiceAccountKey" || -z "$buildType" || -z "$appId" ]]; then
  usage
fi

log_info "Uploading Flutter symbols to Firebase... 📤"

log_info "Checking Firebase CLI... 🔍"
if ! command -v firebase &> /dev/null; then
    log_error "Firebase CLI is not installed. 🚫"
    exit 1
fi
log_success "Firebase CLI is installed. ✅"

log_info "Looking for Google service account key in $googleServiceAccountKey 🔍"
if [[ ! -f "$googleServiceAccountKey" ]]; then
    log_error "Google service account key not found. 🚫 \nPlease download it with script (download_secure_files.sh)"
    exit 1
fi
export GOOGLE_APPLICATION_CREDENTIALS=$googleServiceAccountKey
log_success "Google service account key found. ✅"

log_info "Initializing flutter symbols source path based on build type... 🔍"
case $buildType in
  apk) sourcePath=$APK_FLUTTER_SYMBOLS ;;
  aab) sourcePath=$AAB_FLUTTER_SYMBOLS ;;
  ipa) sourcePath=$IPA_FLUTTER_SYMBOLS ;;
  *) 
    log_error "Invalid build type specified. 🚫"
    exit 1
    ;;
esac
log_success "Source path initialized to $sourcePath. ✅"

log_info "Checking Flutter symbols in $sourcePath... 🔍"
if [[ ! -d "$sourcePath" ]]; then
    log_error "Flutter symbols not found. 🚫"
    exit 1
fi
log_success "Flutter symbols found. ✅"

log_info "Uploading... 📤"
firebase crashlytics:symbols:upload --app $appId $sourcePath || {
    log_error "Failed to upload Flutter symbols to Firebase. 💔"
    exit 1
}
log_success "Uploaded. 🚀"

log_success "Flutter symbols uploaded to Firebase. 🚀"