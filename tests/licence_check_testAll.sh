#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

licence_check_testAll() {
  # 🔢 Ensures consistent numeric formatting
  export LC_NUMERIC=C

  # 🛡️ MASTER SAFETY WRAPPER
  # If we are in a sensitive area, move the entire execution to /tmp
  if [[ "$PWD" == "$HOME"* ]] && [[ "$PWD" != *"/tmp/"* ]]; then
    local REAL_PROJECT_DIR="$PWD"
    local MASTER_SANDBOX=$(mktemp -d -t license-check-MASTER-XXXXXXXXXX)
    
    echo "⚠️  Live directory detected. Moving execution to Sandbox..." >&2
    echo "📁 Sandbox: $MASTER_SANDBOX" >&2
    
    # Ensure we return home and clean up /tmp on finish
    trap 'cd "$REAL_PROJECT_DIR"; rm -rf "$MASTER_SANDBOX"; echo "🧹 Sandbox cleaned. Returned to: $REAL_PROJECT_DIR"' EXIT
    
    cd "$MASTER_SANDBOX" || return 1
    
    # Mocking the local environment so license_check finds what it needs
    # inside this specific sandbox
    echo "Mock License Header" > license.small
    echo "Full License Text" > LICENSE
  fi

  # ---------------------------------------------------------------------------
  # Test Suite Definition
  # ---------------------------------------------------------------------------
  local test_suites=(
    "testLicenseCheckFindUp"
    "testLicenseCheckMultiFile"
    "testLicenseCheck"
    "testLicenseCheckOverwrite"
    "testLicenseCheckRepeatedExecution"
    "testLicenseCheckChangeScenarios"
    "testLicenseCheckEmptyLine"
  )

  local ignored_suites=()

  echo "🚀 Running License Check Test Suite..." >&2
  
  # Execute the runner. Since we are now in /tmp, 
  # any "find ." or "rm" is 100% safe.
  bashTestRunner test_suites ignored_suites
  
  return $?
}
