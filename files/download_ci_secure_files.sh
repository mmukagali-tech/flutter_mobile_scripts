#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


log_info "Downloading secure files... 📂"
    
export SECURE_FILES_DOWNLOAD_PATH=".secure_files"
curl --silent "https://gitlab.com/gitlab-org/incubation-engineering/mobile-devops/download-secure-files/-/raw/main/installer" | bash

log_info "Checking secure files... 🔍"
if [[ -d "$SECURE_FILES" ]]; then
    log_success "Secure files directory exists. 📂"
    log_info "Listing files in secure files directory... 📄"
    ls -l "$SECURE_FILES"
else
    log_error "Secure files directory does not exist. 🚫"
    exit 1
fi