#!/bin/bash

# Define constants
ROM="lineage"
DEVICE="laurel_sprout"
BUILD_TYPE="userdebug"

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to handle errors
handle_error() {
    echo
    echo -e "${RED}Error occurred $(date +%H:%M:%S)${NC}"
    echo
    exit 1
}

# Trap errors
trap 'handle_error' ERR

# Source the environment setup script
echo
echo -e "${YELLOW}Sourcing build/envsetup.sh...${NC}"
echo
source build/envsetup.sh || handle_error

# Start timer
TIME_START=$(date +%s.%N)

# Lunch build
echo
echo -e "${YELLOW}Running lunch for $DEVICE $BUILD_TYPE...${NC}"
echo
lunch_cmd="lunch ${ROM}_${DEVICE}-${BUILD_TYPE}"
if ! $lunch_cmd; then
    echo -e "${RED}Error occurred. Trying alternative lunch command...${NC}"
    lunch_cmd="lunch ${ROM}_${DEVICE}-ap1a-${BUILD_TYPE}"
    if ! $lunch_cmd; then
        echo -e "${RED}Error occurred. Trying another alternative lunch command...${NC}"
        lunch_cmd="brunch $DEVICE $BUILD_TYPE"
        if ! $lunch_cmd; then
            handle_error
        fi
    fi
fi

# Clean up
m installclean

# Build target files package and otatools
echo
echo -e "${YELLOW}Building target-files-package and otatools...${NC}"
echo
mka target-files-package otatools || handle_error

# Define file paths
target_files="signed-target_files.zip"
ota_update_file="${ROM}_${DEVICE}-signed-ota_update.zip"

# Remove previous files if they exist
for file in "$target_files" "$ota_update_file"; do
    if [ -e "$file" ]; then
        rm -rf "$file"
        echo -e "${RED}Removed Previous $file${NC}"
    else
        echo -e "${RED}Previous $file does not exist${NC}"
    fi
done

# Sign target files apks
echo
echo -e "${YELLOW}Signing target files apks...${NC}"
echo
sign_target_files_apks_opts=(
    -o
    -d ~/.android-certs
    --extra_apks AdServicesApk.apk=$HOME/.android-certs/releasekey
    --extra_apks HalfSheetUX.apk=$HOME/.android-certs/releasekey
    --extra_apks OsuLogin.apk=$HOME/.android-certs/releasekey
    --extra_apks SafetyCenterResources.apk=$HOME/.android-certs/releasekey
    --extra_apks ServiceConnectivityResources.apk=$HOME/.android-certs/releasekey
    --extra_apks ServiceUwbResources.apk=$HOME/.android-certs/releasekey
    --extra_apks ServiceWifiResources.apk=$HOME/.android-certs/releasekey
    --extra_apks WifiDialog.apk=$HOME/.android-certs/releasekey
    --extra_apks com.android.adbd.apex=$HOME/.android-certs/com.android.adbd
    --extra_apks com.android.adservices.apex=$HOME/.android-certs/com.android.adservices
    --extra_apks com.android.adservices.api.apex=$HOME/.android-certs/com.android.adservices.api
    --extra_apks com.android.appsearch.apex=$HOME/.android-certs/com.android.appsearch
    --extra_apks com.android.art.apex=$HOME/.android-certs/com.android.art
    --extra_apks com.android.bluetooth.apex=$HOME/.android-certs/com.android.bluetooth
    --extra_apks com.android.btservices.apex=$HOME/.android-certs/com.android.btservices
    --extra_apks com.android.cellbroadcast.apex=$HOME/.android-certs/com.android.cellbroadcast
    --extra_apks com.android.compos.apex=$HOME/.android-certs/com.android.compos
    --extra_apks com.android.configinfrastructure.apex=$HOME/.android-certs/com.android.configinfrastructure
    --extra_apks com.android.connectivity.resources.apex=$HOME/.android-certs/com.android.connectivity.resources
    --extra_apks com.android.conscrypt.apex=$HOME/.android-certs/com.android.conscrypt
    --extra_apks com.android.devicelock.apex=$HOME/.android-certs/com.android.devicelock
    --extra_apks com.android.extservices.apex=$HOME/.android-certs/com.android.extservices
    --extra_apks com.android.graphics.pdf.apex
