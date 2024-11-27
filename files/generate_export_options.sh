#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


usage() {
  echo "Usage: $0 -p <provisioningProfile> -c <certificate> -b <bundleID> -t <teamID> -m <method> -o <outputFilePath>"
  echo ""
  echo "Description:"
  echo "  This script generates an ExportOptions.plist file dynamically for use with Xcode builds."
  echo ""
  echo "Arguments:"
  echo "  -p  Provisioning profile name (e.g., 'MyApp Distribution')"
  echo "  -c  Signing certificate name (e.g., 'Apple Distribution')"
  echo "  -b  Bundle ID (e.g., 'com.example.MyApp')"
  echo "  -t  Apple Developer Team ID (e.g., 'R2TFLUFQCZ')"
  echo "  -m  Export method ('app-store-connect', 'ad-hoc', 'development')"
  echo ""
  echo "Example:"
  echo "  $0 -p \"MyApp Distr Profile\" -c \"Apple Distribution\" -b \"com.example.MyApp\" -t \"R2TFLUFQCZ\" -m \"app-store-connect\""
  exit 1
}

# Parse command-line arguments
while getopts "p:c:b:t:m:" opt; do
  case $opt in
    p) provisioningProfile="$OPTARG" ;;
    c) certificate="$OPTARG" ;;
    b) bundleID="$OPTARG" ;;
    t) teamID="$OPTARG" ;;
    m) method="$OPTARG" ;;
    *) usage ;;
  esac
done

# Check if required arguments are provided
if [[ -z "$provisioningProfile" || -z "$certificate" || -z "$bundleID" || -z "$teamID" || -z "$method" ]]; then
  usage  # Exit and show usage if any argument is missing
fi

# Check if the output directory is writable
if [[ ! -w "$(dirname "$EXPORT_OPTIONS_PLIST")" ]]; then
  log_error "Output directory is not writable. Check permissions."
  exit 1
fi

# Ensure the output directory exists
outputDir=$(dirname "$EXPORT_OPTIONS_PLIST")
if [[ ! -d "$outputDir" ]]; then
  log_info "Creating output directory: $outputDir"
  mkdir -p "$outputDir"
fi

# Generate ExportOptions.plist content
cat > "$EXPORT_OPTIONS_PLIST" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>destination</key>
  <string>export</string>
  <key>method</key>
  <string>${method}</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>${bundleID}</key>
    <string>${provisioningProfile}</string>
  </dict>
  <key>signingCertificate</key>
  <string>${certificate}</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>teamID</key>
  <string>${teamID}</string>
  <key>uploadSymbols</key>
  <true/>
</dict>
</plist>
EOL

log_success "Export options file has been created at $EXPORT_OPTIONS_PLIST"
