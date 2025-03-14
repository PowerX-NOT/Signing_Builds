#!/bin/bash

# lunch ROM_DEVICE-BUILD_TYPE
ROM="lineage"
DEVICE="laurel_sprout"
BUILD_TYPE="userdebug"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

NUM_THREADS=$(nproc)

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

TIME_START=$(date +%s.%N)

# Start the lunch build
echo
echo -e "${YELLOW}Running lunch for $DEVICE $BUILD_TYPE...${NC}"
echo
# Try running the lunch command
if ! lunch ${ROM}_${DEVICE}-${BUILD_TYPE}; then
    echo -e "${RED}Error occurred. Trying alternative lunch command...${NC}"
    # Try an alternative lunch command
    if ! lunch ${ROM}_${DEVICE}-ap4a-${BUILD_TYPE}; then
        echo -e "${RED}Error occurred. Trying another alternative lunch command...${NC}"
        # Try another alternative lunch command
        if ! brunch $DEVICE $BUILD_TYPE; then
            handle_error
        fi
    fi
fi

m installclean

# Build the target files package and otatools
echo
echo -e "${YELLOW}Building target-files-package and otatools...${NC}"
echo
mka target-files-package otatools || handle_error

# Define file paths
target_files="signed-target_files.zip"
ota_update_file="${ROM}_${DEVICE}-signed-ota_update.zip"

# Remove Previous target files if they exist
if [ -e "$target_files" ]; then
    rm -rf "$target_files"
    echo -e "${RED}Removed Previous $target_files${NC}"
else
    echo -e "${RED}Previous $target_files does not exist${NC}"
fi

if [ -e "$ota_update_file" ]; then
    rm -rf "$ota_update_file"
    echo -e "${RED}Removed Previous $ota_update_file${NC}"
else
    echo -e "${RED}Previous $ota_update_file does not exist${NC}"
fi

# Sign the target files apks
echo
echo -e "${YELLOW}Signing target files apks...${NC}"
echo
sign_target_files_apks -o -d ~/.android-certs \
    --extra_apks AdServicesApk.apk=$HOME/.android-certs/releasekey \
    --extra_apks HalfSheetUX.apk=$HOME/.android-certs/releasekey \
    --extra_apks OsuLogin.apk=$HOME/.android-certs/releasekey \
    --extra_apks SafetyCenterResources.apk=$HOME/.android-certs/releasekey \
    --extra_apks ServiceConnectivityResources.apk=$HOME/.android-certs/releasekey \
    --extra_apks ServiceUwbResources.apk=$HOME/.android-certs/releasekey \
    --extra_apks ServiceWifiResources.apk=$HOME/.android-certs/releasekey \
    --extra_apks WifiDialog.apk=$HOME/.android-certs/releasekey \
    --extra_apks com.android.adbd.apex=$HOME/.android-certs/com.android.adbd \
    --extra_apks com.android.adservices.apex=$HOME/.android-certs/com.android.adservices \
    --extra_apks com.android.adservices.api.apex=$HOME/.android-certs/com.android.adservices.api \
    --extra_apks com.android.appsearch.apex=$HOME/.android-certs/com.android.appsearch \
    --extra_apks com.android.art.apex=$HOME/.android-certs/com.android.art \
    --extra_apks com.android.bluetooth.apex=$HOME/.android-certs/com.android.bluetooth \
    --extra_apks com.android.btservices.apex=$HOME/.android-certs/com.android.btservices \
    --extra_apks com.android.cellbroadcast.apex=$HOME/.android-certs/com.android.cellbroadcast \
    --extra_apks com.android.compos.apex=$HOME/.android-certs/com.android.compos \
    --extra_apks com.android.configinfrastructure.apex=$HOME/.android-certs/com.android.configinfrastructure \
    --extra_apks com.android.connectivity.resources.apex=$HOME/.android-certs/com.android.connectivity.resources \
    --extra_apks com.android.conscrypt.apex=$HOME/.android-certs/com.android.conscrypt \
    --extra_apks com.android.devicelock.apex=$HOME/.android-certs/com.android.devicelock \
    --extra_apks com.android.extservices.apex=$HOME/.android-certs/com.android.extservices \
    --extra_apks com.android.graphics.pdf.apex=$HOME/.android-certs/com.android.graphics.pdf \
    --extra_apks com.android.hardware.biometrics.face.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.face.virtual \
    --extra_apks com.android.hardware.biometrics.fingerprint.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.fingerprint.virtual \
    --extra_apks com.android.hardware.boot.apex=$HOME/.android-certs/com.android.hardware.boot \
    --extra_apks com.android.hardware.cas.apex=$HOME/.android-certs/com.android.hardware.cas \
    --extra_apks com.android.hardware.wifi.apex=$HOME/.android-certs/com.android.hardware.wifi \
    --extra_apks com.android.healthfitness.apex=$HOME/.android-certs/com.android.healthfitness \
    --extra_apks com.android.hotspot2.osulogin.apex=$HOME/.android-certs/com.android.hotspot2.osulogin \
    --extra_apks com.android.i18n.apex=$HOME/.android-certs/com.android.i18n \
    --extra_apks com.android.ipsec.apex=$HOME/.android-certs/com.android.ipsec \
    --extra_apks com.android.media.apex=$HOME/.android-certs/com.android.media \
    --extra_apks com.android.media.swcodec.apex=$HOME/.android-certs/com.android.media.swcodec \
    --extra_apks com.android.mediaprovider.apex=$HOME/.android-certs/com.android.mediaprovider \
    --extra_apks com.android.nearby.halfsheet.apex=$HOME/.android-certs/com.android.nearby.halfsheet \
    --extra_apks com.android.networkstack.tethering.apex=$HOME/.android-certs/com.android.networkstack.tethering \
    --extra_apks com.android.neuralnetworks.apex=$HOME/.android-certs/com.android.neuralnetworks \
    --extra_apks com.android.ondevicepersonalization.apex=$HOME/.android-certs/com.android.ondevicepersonalization \
    --extra_apks com.android.os.statsd.apex=$HOME/.android-certs/com.android.os.statsd \
    --extra_apks com.android.permission.apex=$HOME/.android-certs/com.android.permission \
    --extra_apks com.android.resolv.apex=$HOME/.android-certs/com.android.resolv \
    --extra_apks com.android.rkpd.apex=$HOME/.android-certs/com.android.rkpd \
    --extra_apks com.android.runtime.apex=$HOME/.android-certs/com.android.runtime \
    --extra_apks com.android.safetycenter.resources.apex=$HOME/.android-certs/com.android.safetycenter.resources \
    --extra_apks com.android.scheduling.apex=$HOME/.android-certs/com.android.scheduling \
    --extra_apks com.android.sdkext.apex=$HOME/.android-certs/com.android.sdkext \
    --extra_apks com.android.support.apexer.apex=$HOME/.android-certs/com.android.support.apexer \
    --extra_apks com.android.telephony.apex=$HOME/.android-certs/com.android.telephony \
    --extra_apks com.android.telephonymodules.apex=$HOME/.android-certs/com.android.telephonymodules \
    --extra_apks com.android.tethering.apex=$HOME/.android-certs/com.android.tethering \
    --extra_apks com.android.tzdata.apex=$HOME/.android-certs/com.android.tzdata \
    --extra_apks com.android.uwb.apex=$HOME/.android-certs/com.android.uwb \
    --extra_apks com.android.uwb.resources.apex=$HOME/.android-certs/com.android.uwb.resources \
    --extra_apks com.android.virt.apex=$HOME/.android-certs/com.android.virt \
    --extra_apks com.android.vndk.current.apex=$HOME/.android-certs/com.android.vndk.current \
    --extra_apks com.android.vndk.current.on_vendor.apex=$HOME/.android-certs/com.android.vndk.current.on_vendor \
    --extra_apks com.android.wifi.apex=$HOME/.android-certs/com.android.wifi \
    --extra_apks com.android.wifi.dialog.apex=$HOME/.android-certs/com.android.wifi.dialog \
    --extra_apks com.android.wifi.resources.apex=$HOME/.android-certs/com.android.wifi.resources \
    --extra_apks com.google.pixel.camera.hal.apex=$HOME/.android-certs/com.google.pixel.camera.hal \
    --extra_apks com.google.pixel.vibrator.hal.apex=$HOME/.android-certs/com.google.pixel.vibrator.hal \
    --extra_apks com.qorvo.uwb.apex=$HOME/.android-certs/com.qorvo.uwb \
    --extra_apex_payload_key com.android.adbd.apex=$HOME/.android-certs/com.android.adbd.pem \
    --extra_apex_payload_key com.android.adservices.apex=$HOME/.android-certs/com.android.adservices.pem \
    --extra_apex_payload_key com.android.adservices.api.apex=$HOME/.android-certs/com.android.adservices.api.pem \
    --extra_apex_payload_key com.android.appsearch.apex=$HOME/.android-certs/com.android.appsearch.pem \
    --extra_apex_payload_key com.android.art.apex=$HOME/.android-certs/com.android.art.pem \
    --extra_apex_payload_key com.android.bluetooth.apex=$HOME/.android-certs/com.android.bluetooth.pem \
    --extra_apex_payload_key com.android.btservices.apex=$HOME/.android-certs/com.android.btservices.pem \
    --extra_apex_payload_key com.android.cellbroadcast.apex=$HOME/.android-certs/com.android.cellbroadcast.pem \
    --extra_apex_payload_key com.android.compos.apex=$HOME/.android-certs/com.android.compos.pem \
    --extra_apex_payload_key com.android.configinfrastructure.apex=$HOME/.android-certs/com.android.configinfrastructure.pem \
    --extra_apex_payload_key com.android.connectivity.resources.apex=$HOME/.android-certs/com.android.connectivity.resources.pem \
    --extra_apex_payload_key com.android.conscrypt.apex=$HOME/.android-certs/com.android.conscrypt.pem \
    --extra_apex_payload_key com.android.devicelock.apex=$HOME/.android-certs/com.android.devicelock.pem \
    --extra_apex_payload_key com.android.extservices.apex=$HOME/.android-certs/com.android.extservices.pem \
    --extra_apex_payload_key com.android.graphics.pdf.apex=$HOME/.android-certs/com.android.graphics.pdf.pem \
    --extra_apex_payload_key com.android.hardware.biometrics.face.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.face.virtual.pem \
    --extra_apex_payload_key com.android.hardware.biometrics.fingerprint.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.fingerprint.virtual.pem \
    --extra_apex_payload_key com.android.hardware.boot.apex=$HOME/.android-certs/com.android.hardware.boot.pem \
    --extra_apex_payload_key com.android.hardware.cas.apex=$HOME/.android-certs/com.android.hardware.cas.pem \
    --extra_apex_payload_key com.android.hardware.wifi.apex=$HOME/.android-certs/com.android.hardware.wifi.pem \
    --extra_apex_payload_key com.android.healthfitness.apex=$HOME/.android-certs/com.android.healthfitness.pem \
    --extra_apex_payload_key com.android.hotspot2.osulogin.apex=$HOME/.android-certs/com.android.hotspot2.osulogin.pem \
    --extra_apex_payload_key com.android.i18n.apex=$HOME/.android-certs/com.android.i18n.pem \
    --extra_apex_payload_key com.android.ipsec.apex=$HOME/.android-certs/com.android.ipsec.pem \
    --extra_apex_payload_key com.android.media.apex=$HOME/.android-certs/com.android.media.pem \
    --extra_apex_payload_key com.android.media.swcodec.apex=$HOME/.android-certs/com.android.media.swcodec.pem \
    --extra_apex_payload_key com.android.mediaprovider.apex=$HOME/.android-certs/com.android.mediaprovider.pem \
    --extra_apex_payload_key com.android.nearby.halfsheet.apex=$HOME/.android-certs/com.android.nearby.halfsheet.pem \
    --extra_apex_payload_key com.android.networkstack.tethering.apex=$HOME/.android-certs/com.android.networkstack.tethering.pem \
    --extra_apex_payload_key com.android.neuralnetworks.apex=$HOME/.android-certs/com.android.neuralnetworks.pem \
    --extra_apex_payload_key com.android.ondevicepersonalization.apex=$HOME/.android-certs/com.android.ondevicepersonalization.pem \
    --extra_apex_payload_key com.android.os.statsd.apex=$HOME/.android-certs/com.android.os.statsd.pem \
    --extra_apex_payload_key com.android.permission.apex=$HOME/.android-certs/com.android.permission.pem \
    --extra_apex_payload_key com.android.resolv.apex=$HOME/.android-certs/com.android.resolv.pem \
    --extra_apex_payload_key com.android.rkpd.apex=$HOME/.android-certs/com.android.rkpd.pem \
    --extra_apex_payload_key com.android.runtime.apex=$HOME/.android-certs/com.android.runtime.pem \
    --extra_apex_payload_key com.android.safetycenter.resources.apex=$HOME/.android-certs/com.android.safetycenter.resources.pem \
    --extra_apex_payload_key com.android.scheduling.apex=$HOME/.android-certs/com.android.scheduling.pem \
    --extra_apex_payload_key com.android.sdkext.apex=$HOME/.android-certs/com.android.sdkext.pem \
    --extra_apex_payload_key com.android.support.apexer.apex=$HOME/.android-certs/com.android.support.apexer.pem \
    --extra_apex_payload_key com.android.telephony.apex=$HOME/.android-certs/com.android.telephony.pem \
    --extra_apex_payload_key com.android.telephonymodules.apex=$HOME/.android-certs/com.android.telephonymodules.pem \
    --extra_apex_payload_key com.android.tethering.apex=$HOME/.android-certs/com.android.tethering.pem \
    --extra_apex_payload_key com.android.tzdata.apex=$HOME/.android-certs/com.android.tzdata.pem \
    --extra_apex_payload_key com.android.uwb.apex=$HOME/.android-certs/com.android.uwb.pem \
    --extra_apex_payload_key com.android.uwb.resources.apex=$HOME/.android-certs/com.android.uwb.resources.pem \
    --extra_apex_payload_key com.android.virt.apex=$HOME/.android-certs/com.android.virt.pem \
    --extra_apex_payload_key com.android.vndk.current.apex=$HOME/.android-certs/com.android.vndk.current.pem \
    --extra_apex_payload_key com.android.vndk.current.on_vendor.apex=$HOME/.android-certs/com.android.vndk.current.on_vendor.pem \
    --extra_apex_payload_key com.android.wifi.apex=$HOME/.android-certs/com.android.wifi.pem \
    --extra_apex_payload_key com.android.wifi.dialog.apex=$HOME/.android-certs/com.android.wifi.dialog.pem \
    --extra_apex_payload_key com.android.wifi.resources.apex=$HOME/.android-certs/com.android.wifi.resources.pem \
    --extra_apex_payload_key com.google.pixel.camera.hal.apex=$HOME/.android-certs/com.google.pixel.camera.hal.pem \
    --extra_apex_payload_key com.google.pixel.vibrator.hal.apex=$HOME/.android-certs/com.google.pixel.vibrator.hal.pem \
    --extra_apex_payload_key com.qorvo.uwb.apex=$HOME/.android-certs/com.qorvo.uwb.pem \
    $OUT/obj/PACKAGING/target_files_intermediates/*-target_files*.zip \
    signed-target_files.zip || handle_error

# Create OTA from target files
echo
echo -e "${YELLOW}Creating OTA from target files...${NC}"
echo
ota_from_target_files -k ~/.android-certs/releasekey \
    --block --backup=true --retrofit_dynamic_partitions --max_threads "$NUM_THREADS" \
    signed-target_files.zip \
    $ROM"_"$DEVICE-signed-ota_update.zip || handle_error

# Echo package complete and path of the package
package_path="$(pwd)/$ROM"_"$DEVICE-signed-ota_update.zip"
package_size_gb=$(du -h --apparent-size "$package_path" | awk -F'\t' '{print $1}')
echo
echo -e "${RED}Package complete: ${package_path} (${package_size_gb})${NC}"
echo

# Record the end time for signing
TIME_END=$(date +%s.%N)
elapsed_time=$(echo "($TIME_END - $TIME_START) / 60" | bc -l)
echo -e "${GREEN}### Total time elapsed: ${elapsed_time} minutes ###${NC}"
echo
