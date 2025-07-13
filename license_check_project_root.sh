#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.
license_check_project_root() {
  if [ ! -d ".git" ]; then
    echo "Error: This script must be run from the project root directory (where .git exists)"
    echo "Current directory: $(pwd)"
    exit 1
  fi
}
