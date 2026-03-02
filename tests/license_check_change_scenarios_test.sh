#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

testLicenseCheckChangeScenarios() {
  local initial_dir=$(pwd)
  local SAFE_TEST_ROOT=$(mktemp -d -t license-scenarios-SANDBOX-XXXXXXXXXX)
  trap 'cd "$initial_dir"; rm -rf "$SAFE_TEST_ROOT"' EXIT

  cd "$SAFE_TEST_ROOT" || return 1
  git init -q
  echo "Initial License" > LICENSE
  
  local test_file="logic.sh"
  echo "#!/bin/bash
echo 'original'" > "$test_file"

  local licenses=("License A" "License B" "License C")
  local all_ok=true

  for lic in "${licenses[@]}"; do
    echo "$lic" > license.small
    LICENSE_HEADER="$lic"
    license_check_add_header "$test_file"
    
    if ! grep -q "$lic" "$test_file"; then
      echo "❌ FAIL: Content did not update to $lic" >&2
      all_ok=false
    fi
  done

  if [ "$all_ok" = true ]; then
    echo "✅ PASS: License change scenarios verified in sandbox" >&2
    return 0
  else
    return 1
  fi
}
