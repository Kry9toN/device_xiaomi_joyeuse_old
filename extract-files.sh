#!/bin/bash
#
# Copyright (C) 2018-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

# Required!
export DEVICE=joyeuse
export DEVICE_COMMON=sm6250-common
export VENDOR=xiaomi

export DEVICE_BRINGUP_YEAR=2020

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

KOMODO_ROOT="${MY_DIR}"/../../..

HELPER="${KOMODO_ROOT}/vendor/komodo/build/tools/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

SECTION=
KANG=

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

function blob_fixup() {
    case "${1}" in
    product/lib64/libdpmframework.so)
        patchelf --add-needed "libcutils_shim.so" "${2}"
        ;;
    vendor/lib64/hw/camera.qcom.so)
        patchelf --remove-needed "libMegviiFacepp-0.5.2.so" "${2}"
        patchelf --remove-needed "libmegface.so" "${2}"
        patchelf --add-needed "libshim_megvii.so" "${2}"
        ;;
    esac
}

# Initialize the helper for device
setup_vendor "${DEVICE}" "${VENDOR}" "${KOMODO_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
