#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

testLicenseCheckEmptyLine() {
  local initial_dir=$(pwd)
  local SAFE_TEST_ROOT=$(mktemp -d -t license-empty-SANDBOX-XXXXXXXXXX)
  trap 'cd "$initial_dir"; rm -rf "$SAFE_TEST_ROOT"' EXIT

  cd "$SAFE_TEST_ROOT" || return 1
  git init -q
  echo "Header" > license.small
  echo "Full" > LICENSE
  echo "code_line" > test.js

  LICENSE_HEADER="Header"
  license_check_add_header "test.js"

  # Line 1: License
  # Line 2: Empty
  # Line 3: Code
  if [[ -z $(sed -n '2p' test.js) ]] && [[ $(sed -n '3p' test.js) == "code_line" ]]; then
    echo "✅ PASS: Empty line separator verified" >&2
    return 0
  else
    echo "❌ FAIL: Formatting incorrect in test.js" >&2
    cat -n test.js >&2
    return 1
  fi
}
