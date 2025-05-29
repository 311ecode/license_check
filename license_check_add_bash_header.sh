#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.
license_check_add_bash_header() {
    local file="$1"
        sed -i "1a\\# $LICENSE_HEADER" "$file"
    fi
}