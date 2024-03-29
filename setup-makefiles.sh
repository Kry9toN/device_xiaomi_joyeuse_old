#!/bin/bash
#
# Copyright (C) 2018-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Required!
export DEVICE=joyeuse
export VENDOR=xiaomi

export DEVICE_BRINGUP_YEAR=2020

INITIAL_COPYRIGHT_YEAR=2020

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

KOMODO_ROOT="${MY_DIR}/../../.."

HELPER="${KOMODO_ROOT}/vendor/komodo/build/tools/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Initialize the helper for device
INITIAL_COPYRIGHT_YEAR="$DEVICE_BRINGUP_YEAR"
setup_vendor "${DEVICE}" "${VENDOR}" "${KOMODO_ROOT}" false

# Copyright headers and guards
write_headers "joyeuse"

# The standard common blobs
write_makefiles "${MY_DIR}/proprietary-files.txt" true

# Finish
write_footers
