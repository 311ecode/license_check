#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.
license_check_read_small_license() {
    # Read the entire license.small file as the header (no trimming or processing)
    LICENSE_HEADER=$(cat license.small)
    if [ -z "$LICENSE_HEADER" ]; then
        echo "Error: license.small file is empty"
        exit 1
    fi
}
