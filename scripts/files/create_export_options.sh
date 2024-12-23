#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"

usage() {
cat << EOF
Usage: ${0##*/} [-h] [-p PROVISIONINGPROFILE] [FILE] [-c CERTIFICATE] [FILE] [-b BUNDLEID] [ID] [-t TEAMID] [ID] [-m METHOD] [app-store-connect, ad-hoc, development]
Generate an ExportOptions.plist file for Xcode builds.

    -h                      Display help
    -p PROVISIONINGPROFILE  Provisioning profile name
    -c CERTIFICATE          Signing certificate name
    -b BUNDLEID             Bundle ID
    -t TEAMID               Apple Developer Team ID
    -m METHOD               Export method (app-store-connect, ad-hoc, development)
EOF
}

provisioningProfile=""
certificate=""
bundleID=""
teamID=""
method=""

# Parse command-line arguments
while getopts ":p:c:b:t:m:h" opt; do
    case ${opt} in
        h)
            usage
            exit 0
            ;;
        p)
            provisioningProfile=$OPTARG
            ;;
        c)
            certificate=$OPTARG
            ;;
        b)
            bundleID=$OPTARG
            ;;
        t)
            teamID=$OPTARG
            ;;
        m)
            method=$OPTARG
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

# Check if required arguments are provided
if [[ -z "$provisioningProfile" || -z "$certificate" || -z "$bundleID" || -z "$teamID" || -z "$method" ]]; then
    echo "Missing required arguments" 1>&2
    usage
    exit 1
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
