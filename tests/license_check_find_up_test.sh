#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

testLicenseCheckFindUp() {
  local initial_dir=$(pwd)
  local SAFE_TEST_ROOT=$(mktemp -d -t license-findup-SANDBOX-XXXXXXXXXX)
  trap 'cd "$initial_dir"; rm -rf "$SAFE_TEST_ROOT"' EXIT

  # Create a nested structure inside the sandbox
  mkdir -p "$SAFE_TEST_ROOT/project/a/b/c"
  echo "Header" > "$SAFE_TEST_ROOT/project/license.small"
  echo "Full" > "$SAFE_TEST_ROOT/project/LICENSE"

  # Go into the deepest nested dir
  cd "$SAFE_TEST_ROOT/project/a/b/c" || return 1

  # Mock findUpFile to be absolute and scoped to our /tmp dir
  findUpFile() {
    local start_dir=$(pwd)
    while [[ "$start_dir" != "/" ]]; do
      if [[ -f "$start_dir/$1" ]]; then
        echo "$start_dir"
        return 0
      fi
      start_dir=$(dirname "$start_dir")
    done
    return 1
  }

  # Execute
  license_check

  # Verify we stayed inside /tmp
  if [[ "$(pwd)" != "$SAFE_TEST_ROOT/project" ]]; then
    echo "❌ FAIL: license_check escaped to $(pwd)" >&2
    return 1
  fi

  echo "✅ PASS: Find-Up logic successfully isolated to $SAFE_TEST_ROOT" >&2
  return 0
}
