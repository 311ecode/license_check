#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

testLicenseCheckEmptyLine() {
  local initial_dir=$(pwd)
  local test_dir=$(mktemp -d -t license-empty-line-test-XXXXXXXXXX)
  
  # Improved cleanup trap that handles both directory change AND temp dir removal
  trap 'cd "$initial_dir"; rm -rf "$test_dir"' EXIT
  
  # Setup
  echo "🛠️  Setting up test environment for empty line separator..." >&2
  cd "$test_dir" || return 1
  echo "📁 Test directory: $test_dir" >&2

  # Initialize test repo and license files
  git init
  echo "Full license text" >LICENSE
  echo "Test License Header" >license.small
  echo "🐛 DEBUG: Created license files" >&2

  # Create test files with various comment structures
  local test_files=(
    "shebang_with_comments.sh"
    "comments_at_top.js"
    "mixed_comments.py"
    "no_comments.go"
  )

  # Create files with different comment patterns
  echo "#!/usr/bin/env bash
# This is a regular script comment
# Another regular comment
echo 'Hello World'
function test() {
    # Internal comment
    echo 'test'
}" >shebang_with_comments.sh

  echo "// This is a JavaScript module
// Author: Developer
// Version: 1.0
function hello() {
    console.log('Hello');
}" >comments_at_top.js

  echo "# Python script description
# Usage: python script.py
def main():
    # Function comment
    print('Hello')

if __name__ == '__main__':
    main()" >mixed_comments.py

  echo 'package main

import "fmt"

func main() {
    fmt.Println("Hello")
}' >no_comments.go

  # Store original contents for verification
  declare -A original_contents
  for file in "${test_files[@]}"; do
    original_contents["$file"]=$(cat "$file")
    echo "🐛 DEBUG: Original $file:" >&2
    cat -n "$file" >&2
    echo "---" >&2
  done

  # Apply license headers
  echo "🔄 Adding license headers..." >&2
  license_check_read_small_license
  for file in "${test_files[@]}"; do
    license_check_add_header "$file"
  done

  # Verify results
  local all_ok=true

  for file in "${test_files[@]}"; do
    echo "🔍 Verifying $file..." >&2

    # Check license header is present
    if ! grep -q "Test License Header" "$file"; then
      echo "❌ FAIL: License header missing from $file" >&2
      all_ok=false
      continue
    fi

    # Verify empty line separator exists and is correctly positioned
    case "$file" in
    shebang_with_comments.sh)
      local first_line=$(sed -n '1p' "$file")
      local second_line=$(sed -n '2p' "$file")
      local third_line=$(sed -n '3p' "$file")
      local fourth_line=$(sed -n '4p' "$file")

      if [[ $first_line == "#!/usr/bin/env bash" ]]; then
        echo "✅ PASS: Shebang preserved in $file" >&2
      else
        echo "❌ FAIL: Shebang not preserved in $file" >&2
        all_ok=false
      fi

      if [[ $second_line =~ ^\#\ Test\ License\ Header ]]; then
        echo "✅ PASS: License header correctly placed in $file" >&2
      else
        echo "❌ FAIL: License header wrong position in $file" >&2
        all_ok=false
      fi

      if [[ -z $third_line ]]; then
        echo "✅ PASS: Mandatory empty line present in $file" >&2
      else
        echo "❌ FAIL: Missing mandatory empty line in $file" >&2
        echo "🐛 DEBUG: Third line is: '$third_line'" >&2
        all_ok=false
      fi

      if [[ $fourth_line =~ ^\#\ This\ is\ a\ regular\ script\ comment ]]; then
        echo "✅ PASS: Original comments preserved in $file" >&2
      else
        echo "❌ FAIL: Original comments not preserved in $file" >&2
        echo "🐛 DEBUG: Fourth line is: '$fourth_line'" >&2
        all_ok=false
      fi
      ;;

    *)
      local first_line=$(sed -n '1p' "$file")
      local second_line=$(sed -n '2p' "$file")
      local third_line=$(sed -n '3p' "$file")

      if [[ $first_line =~ (\/\/|#)\ Test\ License\ Header ]]; then
        echo "✅ PASS: License header correctly placed in $file" >&2
      else
        echo "❌ FAIL: License header wrong format in $file" >&2
        echo "🐛 DEBUG: First line is: '$first_line'" >&2
        all_ok=false
      fi

      if [[ -z $second_line ]]; then
        echo "✅ PASS: Mandatory empty line present in $file" >&2
      else
        echo "❌ FAIL: Missing mandatory empty line in $file" >&2
        echo "🐛 DEBUG: Second line is: '$second_line'" >&2
        all_ok=false
      fi

      # Check that original content starts after empty line
      case "$file" in
      comments_at_top.js)
        if [[ $third_line =~ ^\/\/\ This\ is\ a\ JavaScript\ module ]]; then
          echo "✅ PASS: Original content preserved in $file" >&2
        else
          echo "❌ FAIL: Original content not preserved in $file" >&2
          echo "🐛 DEBUG: Third line is: '$third_line'" >&2
          all_ok=false
        fi
        ;;
      mixed_comments.py)
        if [[ $third_line =~ ^\#\ Python\ script\ description ]]; then
          echo "✅ PASS: Original content preserved in $file" >&2
        else
          echo "❌ FAIL: Original content not preserved in $file" >&2
          echo "🐛 DEBUG: Third line is: '$third_line'" >&2
          all_ok=false
        fi
        ;;
      no_comments.go)
        if [[ $third_line == "package main" ]]; then
          echo "✅ PASS: Original content preserved in $file" >&2
        else
          echo "❌ FAIL: Original content not preserved in $file" >&2
          echo "🐛 DEBUG: Third line is: '$third_line'" >&2
          all_ok=false
        fi
        ;;
      esac
      ;;
    esac

    # Show final file structure
    echo "🐛 DEBUG: Final content of $file:" >&2
    cat -n "$file" >&2
    echo "---" >&2
  done

  # Test that running again doesn't break the format
  echo "🔄 Testing repeated application..." >&2
  for file in "${test_files[@]}"; do
    license_check_add_header "$file"
  done

  # Verify structure is still correct after second run
  for file in "${test_files[@]}"; do
    local header_count=$(grep -c "Test License Header" "$file")
    if [ "$header_count" -eq 1 ]; then
      echo "✅ PASS: $file still has exactly one header after repeat" >&2
    else
      echo "❌ FAIL: $file has $header_count headers after repeat" >&2
      all_ok=false
    fi

    # Count empty lines - should still have exactly one after license
    local empty_line_position=""
    case "$file" in
    shebang_with_comments.sh)
      empty_line_position=$(sed -n '3p' "$file")
      ;;
    *)
      empty_line_position=$(sed -n '2p' "$file")
      ;;
    esac

    if [[ -z $empty_line_position ]]; then
      echo "✅ PASS: $file maintains empty line separator after repeat" >&2
    else
      echo "❌ FAIL: $file lost empty line separator after repeat" >&2
      all_ok=false
    fi
  done

  # Final explicit cleanup message (trap will handle actual cleanup)
  echo "🧹 Cleaning up test environment..." >&2
  
  if [ "$all_ok" = true ]; then
    echo "🎉 All empty line separator tests passed successfully!" >&2
    return 0
  else
    echo "💥 Some empty line separator tests failed" >&2
    return 1
  fi
}
