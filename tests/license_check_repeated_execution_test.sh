#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

testLicenseCheckRepeatedExecution() {
  local initial_dir=$(pwd)
  trap 'cd "$initial_dir"' EXIT

  # Setup
  echo "🛠️  Setting up test environment for repeated execution..." >&2
  local test_dir=$(mktemp -d -t license-repeated-test-XXXXXXXXXX)
  cd "$test_dir" || return 1
  echo "📁 Test directory: $test_dir" >&2

  # Initialize test repo and license files
  git init
  echo "Full license text" >LICENSE
  echo "Test Copyright Header" >license.small
  echo "🐛 DEBUG: Created license files" >&2

  # Create test files with different structures
  local test_files=(
    "script_with_shebang.sh"
    "script_without_shebang.sh"
    "javascript_file.js"
    "python_file.py"
    "go_file.go"
    "typescript_file.tsx"
  )

  # Create content for each file type
  echo "#!/usr/bin/env bash
echo 'This is a bash script'
# Some comment
function test_function() {
    echo 'Hello World'
}" >script_with_shebang.sh

  echo "# This is a bash script without shebang
echo 'Hello'
# Another comment
exit 0" >script_without_shebang.sh

  echo "// This is a JavaScript file
function testFunction() {
    console.log('Hello World');
}

module.exports = testFunction;" >javascript_file.js

  echo "# This is a Python file
def test_function():
    print('Hello World')

if __name__ == '__main__':
    test_function()" >python_file.py

  echo 'package main

import "fmt"

func main() {
    fmt.Println("Hello World")
}' >go_file.go

  echo "import React from 'react';

const TestComponent: React.FC = () => {
    return <div>Hello World</div>;
};

export default TestComponent;" >typescript_file.tsx

  # Read the license header
  license_check_read_small_license
  echo "🐛 DEBUG: LICENSE_HEADER='$LICENSE_HEADER'" >&2

  # Store original file contents and checksums
  declare -A original_contents
  declare -A original_line_counts
  for file in "${test_files[@]}"; do
    original_contents["$file"]=$(cat "$file")
    original_line_counts["$file"]=$(wc -l <"$file")
    echo "🐛 DEBUG: Original $file has ${original_line_counts["$file"]} lines" >&2
  done

  # Run license check multiple times (5 iterations)
  local iterations=5
  declare -A iteration_contents
  declare -A iteration_line_counts

  for i in $(seq 1 $iterations); do
    echo "🔄 Running license check iteration $i..." >&2

    # Process all files
    for file in "${test_files[@]}"; do
      license_check_add_header "$file"
    done

    # Store results after each iteration
    for file in "${test_files[@]}"; do
      iteration_contents["${file}_${i}"]=$(cat "$file")
      iteration_line_counts["${file}_${i}"]=$(wc -l <"$file")
      echo "🐛 DEBUG: After iteration $i, $file has ${iteration_line_counts["${file}_${i}"]} lines" >&2
    done
  done

  # Verify results
  local all_ok=true

  for file in "${test_files[@]}"; do
    echo "🔍 Verifying $file across all iterations..." >&2

    # Check that license header is present
    if ! grep -q "$LICENSE_HEADER" "$file"; then
      echo "❌ FAIL: License header missing from $file" >&2
      all_ok=false
      continue
    fi

    # Check that we have exactly one license header
    local header_count=$(grep -c "$LICENSE_HEADER" "$file")
    if [ "$header_count" -ne 1 ]; then
      echo "❌ FAIL: Expected 1 license header in $file, found $header_count" >&2
      all_ok=false
    else
      echo "✅ PASS: $file has exactly one license header" >&2
    fi

    # Check that content is identical across iterations 2-5
    local content_consistent=true
    for i in $(seq 2 $iterations); do
      local prev_i=$((i - 1))
      if [ "${iteration_contents["${file}_${i}"]}" != "${iteration_contents["${file}_${prev_i}"]}" ]; then
        echo "❌ FAIL: $file content changed between iterations $prev_i and $i" >&2
        echo "🐛 DEBUG: Iteration $prev_i line count: ${iteration_line_counts["${file}_${prev_i}"]}" >&2
        echo "🐛 DEBUG: Iteration $i line count: ${iteration_line_counts["${file}_${i}"]}" >&2
        content_consistent=false
        all_ok=false
      fi
    done

    if [ "$content_consistent" = true ]; then
      echo "✅ PASS: $file content consistent across all iterations" >&2
    fi

    # Check line count stability (should be original + 2 for header + empty line)
    local final_line_count=${iteration_line_counts["${file}_${iterations}"]}
    local expected_line_count=$((original_line_counts["$file"] + 2))

    if [ "$final_line_count" -eq "$expected_line_count" ]; then
      echo "✅ PASS: $file has correct line count ($final_line_count)" >&2
    else
      echo "❌ FAIL: $file line count wrong. Expected $expected_line_count, got $final_line_count" >&2
      all_ok=false
    fi

    # Verify mandatory empty line after header
    local empty_line_after_header=""
    case "$file" in
    script_with_shebang.sh)
      empty_line_after_header=$(sed -n '3p' "$file")
      ;;
    *)
      empty_line_after_header=$(sed -n '2p' "$file")
      ;;
    esac

    if [[ -z $empty_line_after_header ]]; then
      echo "✅ PASS: $file has mandatory empty line after header" >&2
    else
      echo "❌ FAIL: $file missing mandatory empty line after header" >&2
      echo "🐛 DEBUG: Line after header: '$empty_line_after_header'" >&2
      all_ok=false
    fi

    # Show final file structure for debugging
    echo "🐛 DEBUG: Final content of $file:" >&2
    cat -n "$file" >&2
    echo "---" >&2
  done

  # Cleanup
  echo "🧹 Cleaning up test environment..." >&2
  cd "$initial_dir" && rm -rf "$test_dir"

  if [ "$all_ok" = true ]; then
    echo "🎉 All repeated execution tests passed successfully!" >&2
    return 0
  else
    echo "💥 Some repeated execution tests failed" >&2
    return 1
  fi
}
