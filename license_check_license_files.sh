#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.
license_check_license_files() {
  if [ ! -f "license.small" ]; then
    echo "Error: license.small file not found in project root"
    exit 1
  fi

  if [ ! -f "LICENSE" ]; then
    echo "Error: LICENSE file not found in project root"
    exit 1
  fi
}
