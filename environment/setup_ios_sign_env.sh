#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


# Function to display usage instructions
usage() {
    echo "Usage: $0 [-h] [-c CERTIFICATE] [FILE] [-p PASSWORD] [PASSWORD] [-m PROFILE] [FILE]"
    echo "  -h                    Display help"
    echo "  -c CERTIFICATE        Path to the .p12 certificate file"
    echo "  -p PASSWORD           Password for the certificate's private key"
    echo "  -m PROFILE            Path to the .mobileprovision file"
}

while getopts ":c:p:m:h" opt; do
    case ${opt} in
        h)
            usage
            exit 0
            ;;
        c)
            certificatePath=$OPTARG
            ;;
        p)
            keyPassword=$OPTARG
            ;;
        m)
            provisioningProfilePath=$OPTARG
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

echo "certificatePath: $certificatePath"
echo "keyPassword: $keyPassword"
echo "provisioningProfilePath: $provisioningProfilePath"

# Check if required arguments are provided
if [[ -z "$certificatePath" || -z "$keyPassword" || -z "$provisioningProfilePath" ]]; then
    usage
    exit 1
fi



log_info "Setting up iOS code signing... 🛠"

sh scripts/files/temp_keychain_check.sh

ls -l "$SECURE_FILES"

if [[ ! -f "$certificatePath" ]]; then
    log_error "Certificate file not found. 🚫"
    exit 1
fi

if [[ ! -f "$provisioningProfilePath" ]]; then
    log_error "Provisioning profile file not found. 🚫"
    exit 1
fi

# Checking is certificate already installed

# Extract the SHA-1 hash of the certificate
# certHash=$(openssl pkcs12 -in "$PROJECT_ROOT/$certificatePath" -nokeys -passin pass:"$keyPassword" -clcerts -nodes -legacy | \
#         openssl x509 -noout -fingerprint | awk -F= '{print $2}' | tr -d ':')
# if [[ -z "$certHash" ]]; then
#     log_error "Failed to extract certificate hash. 🚫"
#     exit 1
# fi

# Check if the certificate exists in the keychain
# if security find-identity -v -p codesigning "$TEMP_KEYCHAIN" | grep -q "$certHash"; then
#     log_info "Certificate already exists in the keychain. ✅"
# else
#     log_info "Importing certificate... 📂"
#     security import "$certificatePath" -k "$TEMP_KEYCHAIN" -P "$keyPassword" -A -t cert -f pkcs12 || {
#         log_error "Failed to install the certificate. 🚫"
#         exit 1
#     }
#     security set-key-partition-list -S apple-tool:,apple: -k "$TEMP_KEYCHAIN_PASSWORD" "$TEMP_KEYCHAIN" || {
#         log_error "Failed to set key partition list. 🚫"
#         exit 1
#     }
#     log_success "Certificate installed successfully. 🚀"
# fi


log_info "Importing certificate... 📂"
security import "$certificatePath" -k "$TEMP_KEYCHAIN" -P "$keyPassword" -A -t cert -f pkcs12 || {
    log_error "Failed to install the certificate. 🚫"
    exit 1
}
security set-key-partition-list -S apple-tool:,apple: -k "$TEMP_KEYCHAIN_PASSWORD" "$TEMP_KEYCHAIN" || {
    log_error "Failed to set key partition list. 🚫"
    exit 1
}
log_success "Certificate installed successfully. 🚀"

provisioningProfileUUID=$(security cms -D -i "$PROJECT_ROOT/$provisioningProfilePath" | plutil -extract UUID raw -)
existingProfile=$(find ~/Library/MobileDevice/Provisioning\ Profiles/ -name "$provisioningProfileUUID.mobileprovision")

if [[ -n "$existingProfile" ]]; then
    log_info "Provisioning profile is already imported. ✅"
else
    log_info "Importing provisioning profile... 📄"
    cp "$provisioningProfilePath" ~/Library/MobileDevice/Provisioning\ Profiles/ || {
        log_error "Failed to copy the provisioning profile. 🚫"
        exit 1
    }
    log_success "Provisioning profile installed successfully. 🚀"
fi

log_success "iOS code signing setup complete. 🎯"
