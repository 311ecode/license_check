#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

testLicenseCheckFindUp() {
  local initial_dir=$(pwd)
  local test_dir=$(mktemp -d -t license-findup-XXXXXXXXXX)
  trap 'cd "$initial_dir"; rm -rf "$test_dir"' EXIT

  # Setup project
  mkdir -p "$test_dir/my_project/src/components/ui"
  echo "Full License" > "$test_dir/my_project/LICENSE"
  echo "Small License Header" > "$test_dir/my_project/license.small"
  echo "echo 'root script'" > "$test_dir/my_project/root_script.sh"
  echo "console.log('nested')" > "$test_dir/my_project/src/components/ui/button.ts"

  # Go deep
  cd "$test_dir/my_project/src/components/ui" || return 1

  # Execute
  license_check

  # After execution, we are at the project root because of the 'cd' in the script
  local current_root=$(pwd)
  local all_ok=true

  # Verify relative to the NEW root
  if ! grep -q "Small License Header" "$current_root/src/components/ui/button.ts"; then
    echo "❌ FAIL: Nested file button.ts was not updated" >&2
    all_ok=false
  fi

  if ! grep -q "Small License Header" "$current_root/root_script.sh"; then
    echo "❌ FAIL: Root script was not updated" >&2
    all_ok=false
  fi

  if [ "$all_ok" = true ]; then
    echo "🎉 Find-Up integration tests passed!" >&2
    return 0
  fi
  return 1
}
