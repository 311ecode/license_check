#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

testLicenseCheckOverwrite() {
  local initial_dir=$(pwd)
  trap 'cd "$initial_dir"' EXIT

  # Setup
  echo "🛠️  Setting up test environment..." >&2
  local test_dir=$(mktemp -d -t license-overwrite-test-XXXXXXXXXX)
  cd "$test_dir" || return 1
  echo "📁 Test directory: $test_dir" >&2

  # Initialize test repo and license files
  git init
  echo "Full license text" >LICENSE
  echo "Old Copyright Header" >license.small
  echo "🐛 DEBUG: Created initial license files" >&2

  # Create multiple test files with different structures
  local test_files=(
    "script_with_shebang.sh"
    "script_without_shebang.sh"
    "module.js"
    "component.tsx"
    "program.go"
    "app.py"
  )

  # Create content for each file type
  echo "#!/usr/bin/env bash
echo 'Hello Bash'
function test() {
    echo 'test function'
}" >script_with_shebang.sh

  echo "# Bash script without shebang
echo 'Hello'
exit 0" >script_without_shebang.sh

  echo "// JavaScript module
function hello() {
    console.log('Hello World');
}
module.exports = hello;" >module.js

  echo "import React from 'react';
const Component = () => {
    return <div>Hello</div>;
};
export default Component;" >component.tsx

  echo 'package main
import "fmt"
func main() {
    fmt.Println("Hello")
}' >program.go

  echo "# Python script
def hello():
    print('Hello World')

if __name__ == '__main__':
    hello()" >app.py

  # Store original content for comparison
  declare -A original_contents
  declare -A original_line_counts
  for file in "${test_files[@]}"; do
    original_contents["$file"]=$(cat "$file")
    original_line_counts["$file"]=$(wc -l <"$file")
    echo "🐛 DEBUG: Original $file has ${original_line_counts["$file"]} lines" >&2
  done

  # Process with old license
  echo "🔄 Processing with old license..." >&2
  license_check_read_small_license
  echo "🐛 DEBUG: Old LICENSE_HEADER='$LICENSE_HEADER'" >&2

  for file in "${test_files[@]}"; do
    license_check_add_header "$file"
  done

  # Verify old license is added correctly
  local old_license_ok=true
  for file in "${test_files[@]}"; do
    if ! grep -q "Old Copyright Header" "$file"; then
      echo "❌ FAIL: Old license header not added to $file" >&2
      old_license_ok=false
    else
      echo "✅ PASS: Old license header added to $file" >&2
    fi
  done

  if [ "$old_license_ok" = false ]; then
    cd "$initial_dir" && rm -rf "$test_dir"
    return 1
  fi

  # Store content after first license application
  declare -A first_license_contents
  declare -A first_license_line_counts
  for file in "${test_files[@]}"; do
    first_license_contents["$file"]=$(cat "$file")
    first_license_line_counts["$file"]=$(wc -l <"$file")
    echo "🐛 DEBUG: After old license, $file has ${first_license_line_counts["$file"]} lines" >&2
  done

  # Change the license content
  echo "New Copyright Header" >license.small
  echo "🐛 DEBUG: Updated license.small content:" >&2
  cat license.small >&2

  # Process with new license (should remove old and add new)
  echo "🔄 Processing with new license..." >&2
  license_check_read_small_license
  echo "🐛 DEBUG: New LICENSE_HEADER='$LICENSE_HEADER'" >&2

  for file in "${test_files[@]}"; do
    license_check_add_header "$file"
  done

  # Verify results
  local all_ok=true

  for file in "${test_files[@]}"; do
    echo "🔍 Verifying $file after license change..." >&2

    # Check that old license is gone
    if grep -q "Old Copyright Header" "$file"; then
      echo "❌ FAIL: Old license header still present in $file" >&2
      all_ok=false
    else
      echo "✅ PASS: Old license header removed from $file" >&2
    fi

    # Check that new license is present
    if grep -q "New Copyright Header" "$file"; then
      echo "✅ PASS: New license header added to $file" >&2
    else
      echo "❌ FAIL: New license header missing from $file" >&2
      all_ok=false
    fi

    # Verify we only have one instance of the new header
    local new_header_count=$(grep -c "New Copyright Header" "$file")
    if [ "$new_header_count" -eq 1 ]; then
      echo "✅ PASS: Exactly one new license header in $file" >&2
    else
      echo "❌ FAIL: Expected 1 new license header in $file, found $new_header_count" >&2
      all_ok=false
    fi

    # Verify no instances of old header remain
    local old_header_count=$(grep -c "Old Copyright Header" "$file")
    if [ "$old_header_count" -eq 0 ]; then
      echo "✅ PASS: No old license headers remain in $file" >&2
    else
      echo "❌ FAIL: Found $old_header_count old license headers still in $file" >&2
      all_ok=false
    fi

    # Verify original content is preserved (accounting for new format with empty line)
    case "$file" in
    script_with_shebang.sh)
      # For shebang files: shebang, license, empty line, then original content
      local first_line=$(sed -n '1p' "$file")
      local fourth_line_onwards=$(tail -n +4 "$file")
      local original_without_shebang=$(tail -n +2 <<<"${original_contents["$file"]}")

      if [[ $first_line == "#!/usr/bin/env bash" ]]; then
        echo "✅ PASS: Shebang preserved as first line in $file" >&2
      else
        echo "❌ FAIL: Shebang not preserved correctly in $file. First line: '$first_line'" >&2
        all_ok=false
      fi

      if [[ $fourth_line_onwards == "$original_without_shebang" ]]; then
        echo "✅ PASS: Original content preserved in $file" >&2
      else
        echo "❌ FAIL: Original content not preserved in $file" >&2
        echo "🐛 DEBUG: Expected: '$original_without_shebang'" >&2
        echo "🐛 DEBUG: Got: '$fourth_line_onwards'" >&2
        all_ok=false
      fi

      # Verify empty line separator
      local third_line=$(sed -n '3p' "$file")
      if [[ -z $third_line ]]; then
        echo "✅ PASS: Empty line separator present in $file" >&2
      else
        echo "❌ FAIL: Missing empty line separator in $file" >&2
        all_ok=false
      fi
      ;;
    *)
      # For non-shebang files: license, empty line, then original content
      local third_line_onwards=$(tail -n +3 "$file")
      if [[ $third_line_onwards == "${original_contents["$file"]}" ]]; then
        echo "✅ PASS: Original content preserved in $file" >&2
      else
        echo "❌ FAIL: Original content not preserved in $file" >&2
        echo "🐛 DEBUG: Expected: '${original_contents["$file"]}'" >&2
        echo "🐛 DEBUG: Got: '$third_line_onwards'" >&2
        all_ok=false
      fi

      # Verify empty line separator
      local second_line=$(sed -n '2p' "$file")
      if [[ -z $second_line ]]; then
        echo "✅ PASS: Empty line separator present in $file" >&2
      else
        echo "❌ FAIL: Missing empty line separator in $file" >&2
        all_ok=false
      fi
      ;;
    esac

    # Verify correct comment style for new header
    case "$file" in
    *.js | *.tsx | *.go)
      local first_line=$(head -n 1 "$file")
      if [[ $first_line =~ ^\/\/\ New\ Copyright\ Header ]]; then
        echo "✅ PASS: $file has correct // comment style for new header" >&2
      else
        echo "❌ FAIL: $file has wrong comment style for new header" >&2
        echo "🐛 DEBUG: First line is: '$first_line'" >&2
        all_ok=false
      fi
      ;;
    script_with_shebang.sh)
      local second_line=$(sed -n '2p' "$file")
      if [[ $second_line =~ ^\#\ New\ Copyright\ Header ]]; then
        echo "✅ PASS: $file has correct # comment style after shebang for new header" >&2
      else
        echo "❌ FAIL: $file has wrong comment style after shebang for new header" >&2
        echo "🐛 DEBUG: Second line is: '$second_line'" >&2
        all_ok=false
      fi
      ;;
    *)
      local first_line=$(head -n 1 "$file")
      if [[ $first_line =~ ^\#\ New\ Copyright\ Header ]]; then
        echo "✅ PASS: $file has correct # comment style for new header" >&2
      else
        echo "❌ FAIL: $file has wrong comment style for new header" >&2
        echo "🐛 DEBUG: First line is: '$first_line'" >&2
        all_ok=false
      fi
      ;;
    esac

    # Show final file content for debugging
    echo "🐛 DEBUG: Final content of $file:" >&2
    cat -n "$file" >&2
    echo "---" >&2
  done

  # Cleanup
  echo "🧹 Cleaning up test environment..." >&2
  cd "$initial_dir" && rm -rf "$test_dir"

  if [ "$all_ok" = true ]; then
    echo "🎉 Enhanced license overwrite test passed successfully!" >&2
    return 0
  else
    echo "💥 Enhanced license overwrite test failed" >&2
    return 1
  fi
}
