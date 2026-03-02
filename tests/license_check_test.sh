#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

testLicenseCheck() {
  local initial_dir=$(pwd)
  # Create a dedicated sandbox in /tmp
  local SAFE_TEST_ROOT=$(mktemp -d -t license-check-SANDBOX-XXXXXXXXXX)
  
  # Ensure we clean up ONLY the sandbox on exit
  trap 'cd "$initial_dir"; rm -rf "$SAFE_TEST_ROOT"' EXIT

  echo "🛡️  Sandbox created at: $SAFE_TEST_ROOT" >&2
  cd "$SAFE_TEST_ROOT" || return 1

  # Step 1: Build a dummy project structure
  mkdir -p bin lib src
  echo "Copyright 2026 Sandbox User" > license.small
  echo "Full License Text" > LICENSE
  
  # Create dummy files
  echo "#!/bin/bash" > bin/tool.sh
  echo "function logic() { :; }" > lib/utils.sh
  echo "import os" > src/main.py

  # Step 2: Test project root discovery
  # We mock findUpFile to ensure it stays within our sandbox
  findUpFile() { echo "$SAFE_TEST_ROOT"; }
  export -f findUpFile

  echo "🔍 Testing license_check execution..." >&2
  # Run the actual function
  license_check

  # Step 3: Verify results within sandbox
  local all_ok=true
  if ! grep -q "Copyright 2026 Sandbox User" bin/tool.sh; then
    echo "❌ FAIL: bin/tool.sh was not updated" >&2
    all_ok=false
  fi

  if [ "$all_ok" = true ]; then
    echo "✅ PASS: license_check executed safely within /tmp sandbox" >&2
    return 0
  else
    return 1
  fi
}
