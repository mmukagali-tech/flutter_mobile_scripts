#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"



log_info "Analyzing code for CI... 🔍"

log_info "Checking for flutter_analyze_reporter..."
if ! dart pub global list | grep -q flutter_analyze_reporter; then
    log_warning "flutter_analyze_reporter not found. Installing... 📦"
    dart pub global activate flutter_analyze_reporter && log_success "flutter_analyze_reporter installed."
else
    log_success "flutter_analyze_reporter already installed."
fi

log_info "Running Dart analysis..."
dart analyze --no-fatal-warnings --format=json > analysis.json || {
    log_error "Failed to run analysis. 💔"
    exit 1
}

log_info "Generating analysis report..."
flutter_analyze_reporter --output analysis_report.json --reporter gitlab || {
    log_error "Failed to generate analysis report. 💔"
    exit 1
}

log_success "Code analysis complete. 📋"