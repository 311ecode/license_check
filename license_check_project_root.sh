#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

license_check_project_root() {
  # Defensive check: Ensure the dependency findUpFile is available
  if ! command -v findUpFile &>/dev/null; then
    echo "Error: findUpFile utility not found in PATH or scope." >&2
    exit 1
  fi

  local root_dir
  root_dir=$(findUpFile "license.small")

  if [[ -z "$root_dir" ]]; then
    echo "Error: Could not find 'license.small' in parent directories." >&2
    exit 1
  fi

  cd "$root_dir" || exit 1
}
