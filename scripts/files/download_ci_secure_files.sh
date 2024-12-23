#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

log_info "Downloading secure files... 📂"

export SECURE_FILES_DOWNLOAD_PATH=".secure_files"

# Retry logic for downloading and executing the installer
MAX_RETRIES=5
RETRY_DELAY=2
RETRIES=0

# Function to download and execute the installer
download_and_execute_installer() {
    curl --silent --fail "https://gitlab.com/gitlab-org/incubation-engineering/mobile-devops/download-secure-files/-/raw/main/installer" | bash
}

# Retry loop
until download_and_execute_installer; do
    RETRIES=$((RETRIES+1))
    if [[ $RETRIES -ge $MAX_RETRIES ]]; then
        log_error "Failed to download and execute the installer after $MAX_RETRIES attempts."
        exit 1
    fi
    log_warning "Download failed, retrying in $RETRY_DELAY seconds... (Attempt $RETRIES of $MAX_RETRIES)"
    sleep $RETRY_DELAY
done

log_info "Installer executed successfully."

log_info "Checking secure files... 🔍"
if [[ -d "$SECURE_FILES" ]]; then
    log_success "Secure files directory exists. 📂"
    log_info "Listing files in secure files directory... 📄"
    ls -l "$SECURE_FILES"
else
    log_error "Secure files directory does not exist. 🚫"
    exit 1
fi
