#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
cat << EOF
Usage: ${0##*/} [-hc]
Analyze the code for issues.

    -h                Display help
    -c                CI mode
EOF
}

ci_mode=0

# Parse command-line arguments
while getopts "hc" opt; do
  case $opt in
    h)
        usage
        exit 0
        ;;
    c)
        ci_mode=1
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

if [[ $ci_mode -eq 0 ]]; then
    log_info "Analyzing code... 🔍"
    dart analyze --no-fatal-warnings || {
        log_error "Failed to run analysis. 💔"
        exit 1
    }
    log_success "Code analysis complete. ✅"
    exit 0
fi


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
