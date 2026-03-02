#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

testLicenseCheckRepeatedExecution() {
  local initial_dir=$(pwd)
  local SAFE_TEST_ROOT=$(mktemp -d -t license-repeat-SANDBOX-XXXXXXXXXX)
  trap 'cd "$initial_dir"; rm -rf "$SAFE_TEST_ROOT"' EXIT

  cd "$SAFE_TEST_ROOT" || return 1
  git init -q
  
  local header="Copyright 2026 Stable Header"
  echo "$header" > license.small
  echo "Full License" > LICENSE
  echo "echo 'code'" > test.sh

  # Run the logic 5 times
  for i in {1..5}; do
    LICENSE_HEADER="$header" license_check_add_header "test.sh"
  done

  # Verification
  local header_count=$(grep -c "Copyright 2026 Stable Header" test.sh)
  local total_lines=$(wc -l < test.sh)

  # Expectation: 1 header line + 1 empty line + 1 code line = 3 lines total
  if [ "$header_count" -eq 1 ] && [ "$total_lines" -eq 3 ]; then
    echo "✅ PASS: Repeated execution is stable (exactly 1 header preserved)" >&2
    return 0
  else
    echo "❌ FAIL: Stability check failed. Total lines: $total_lines (Expected 3), Headers found: $header_count (Expected 1)" >&2
    echo "--- File Content ---" >&2
    cat -n test.sh >&2
    return 1
  fi
}
