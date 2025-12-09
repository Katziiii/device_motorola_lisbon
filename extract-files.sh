#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=lisbon
VENDOR=motorola

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup {
    case "$1" in
        vendor/bin/hw/android.hardware.gnss-service.mediatek |\
        vendor/lib64/hw/android.hardware.gnss-impl-mediatek.so)
            "$PATCHELF" --replace-needed "android.hardware.gnss-V1-ndk_platform.so" "android.hardware.gnss-V1-ndk.so" "$2"
            ;;
        vendor/bin/hw/android.hardware.lights-service.mediatek)
            "$PATCHELF" --replace-needed "android.hardware.light-V1-ndk_platform.so" "android.hardware.light-V1-ndk.so" "$2"
            ;;
        vendor/bin/hw/android.hardware.vibrator-service.mediatek)
            "$PATCHELF" --replace-needed "android.hardware.vibrator-V2-ndk_platform.so" "android.hardware.vibrator-V2-ndk.so" "$2"
            ;;
        vendor/bin/hw/vendor.mediatek.hardware.mtkpower@1.0-service)
            "$PATCHELF" --replace-needed "android.hardware.power-V2-ndk_platform.so" "android.hardware.power-V2-ndk.so" "$2"
            ;;
        vendor/etc/init/android.hardware.neuralnetworks-shim-service-mtk.rc)
            sed -i 's/start/enable/' "$2"
            ;;
        vendor/etc/vintf/manifest/manifest_media_c2_V1_2_default.xml)
            sed -i 's/1.1/1.2/' "$2"
            ;;
        vendor/bin/hw/android.hardware.media.c2@1.2-mediatek | vendor/bin/hw/android.hardware.media.c2@1.2-mediatek-64b)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libavservices_minijail_vendor.so" "libavservices_minijail.so" "${2}"
            grep -q "libstagefright_foundation-v32.so" "${2}" || "${PATCHELF}" --add-needed "libstagefright_foundation-v32.so" "${2}"
            ;;
        vendor/lib*/hw/vendor.mediatek.hardware.pq@2.12-impl.so)
            ;&
        vendor/lib*/libmtkcam_stdutils.so)
            ;&
        vendor/lib*/hw/audio.primary.mt6785.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/bin/mnld)
            ;&
        vendor/lib64/hw/android.hardware.sensors@2.X-subhal-mediatek.so)
            ;&
        vendor/lib64/libcam.utils.sensorprovider.so)
            grep -q "libshim_sensors.so" "$2" || "$PATCHELF" --add-needed "libshim_sensors.so" "$2"
            ;;
        vendor/lib64/libmtkcam_featurepolicy.so)
            # evaluateCaptureConfiguration()
            printf '\x28\x02\x80\x52' | dd of="$2" bs=1 seek=$((0x3e828)) count=4 conv=notrunc
            printf '\x28\x02\x80\x52' | dd of="$2" bs=1 seek=$((0x3e8f4)) count=4 conv=notrunc
            ;;
        vendor/lib64/sensors.moto.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
