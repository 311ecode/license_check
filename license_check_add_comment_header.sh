#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

license_check_add_comment_header() {
  local file="$1"

  # Add // style comment header at the beginning of the file
  sed -i "1i\\// $LICENSE_HEADER" "$file"
}
