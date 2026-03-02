#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

license_check_read_small_license() {
  # Read the entire license.small file as the header
  LICENSE_HEADER=$(cat license.small)
  
  if [ -z "$LICENSE_HEADER" ]; then
    echo "Error: license.small file is empty" >&2
    exit 1
  fi
}
