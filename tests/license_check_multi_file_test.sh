#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

testLicenseCheckMultiFile() {
  local initial_dir=$(pwd)
  local SAFE_TEST_ROOT=$(mktemp -d -t license-multi-SANDBOX-XXXXXXXXXX)
  trap 'cd "$initial_dir"; rm -rf "$SAFE_TEST_ROOT"' EXIT

  cd "$SAFE_TEST_ROOT" || return 1
  
  # Initialize a dummy git repo so project discovery works
  git init -q
  echo "Header" > license.small
  echo "Full" > LICENSE

  # Create various file types
  echo "console.log('js')" > test.js
  echo "package main" > test.go
  echo "print('py')" > test.py
  echo "#!/bin/bash" > test.sh

  LICENSE_HEADER="Header"
  license_check_process_all_files

  local all_ok=true
  for f in test.js test.go test.py test.sh; do
    if ! grep -q "Header" "$f"; then
      echo "❌ FAIL: Multi-file check failed for $f" >&2
      all_ok=false
    fi
  done

  if [ "$all_ok" = true ]; then
    echo "✅ PASS: Multi-file sandbox test successful" >&2
    return 0
  else
    return 1
  fi
}
