#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

testLicenseCheckOverwrite() {
  local initial_dir=$(pwd)
  local SAFE_TEST_ROOT=$(mktemp -d -t license-overwrite-SANDBOX-XXXXXXXXXX)
  trap 'cd "$initial_dir"; rm -rf "$SAFE_TEST_ROOT"' EXIT

  cd "$SAFE_TEST_ROOT" || return 1
  git init -q
  
  # Iteration 1: Apply an initial license
  echo "Copyright 2025 Old Corp" > license.small
  echo "echo 'hello'" > test.sh
  LICENSE_HEADER="Copyright 2025 Old Corp" license_check_add_header "test.sh"

  # Iteration 2: Change license.small and re-apply
  echo "Copyright 2026 New Corp" > license.small
  LICENSE_HEADER="Copyright 2026 New Corp" license_check_add_header "test.sh"

  local all_ok=true
  if grep -q "Old Corp" test.sh; then
    echo "❌ FAIL: Old header 'Old Corp' was not removed from test.sh" >&2
    all_ok=false
  fi

  if ! grep -q "New Corp" test.sh; then
    echo "❌ FAIL: New header 'New Corp' was not found in test.sh" >&2
    all_ok=false
  fi

  [ "$all_ok" = true ] && echo "✅ PASS: Overwrite sandbox test successful" >&2
  return $(([ "$all_ok" = true ] ? 0 : 1))
}
