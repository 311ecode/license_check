#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

license_check_license_files() {
  # We assume we are now in the root directory discovered by findUp
  if [ ! -f "license.small" ]; then
    echo "Error: license.small not found at $(pwd)" >&2
    exit 1
  fi

  if [ ! -f "LICENSE" ]; then
    echo "Error: Full LICENSE file not found at $(pwd)" >&2
    exit 1
  fi
}
