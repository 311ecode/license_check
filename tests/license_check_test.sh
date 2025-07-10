#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

testLicenseCheck() {
    local initial_dir=$(pwd)
    trap 'cd "$initial_dir"' EXIT

    # Setup
    echo "🛠️  Setting up test environment..." >&2
    local test_dir=$(mktemp -d -t license-test-XXXXXXXXXX)
    cd "$test_dir" || return 1
    echo "📁 Test directory: $test_dir" >&2

    # Test 1: Check project root validation
    echo "🔍 Testing project root validation..." >&2
    local setup_string='
        git init
        echo "Test license" > LICENSE
        echo "Test small license" > license.small
    '
    eval "$setup_string"
    
    license_check_project_root
    if [ $? -ne 0 ]; then
        echo "❌ FAIL: Project root check failed in git repo" >&2
        cd "$initial_dir" && rm -rf "$test_dir"
        return 1
    fi
    echo "✅ PASS: Project root validation" >&2

    # Test 2: Check license files validation
    echo "🔍 Testing license files validation..." >&2
    license_check_license_files
    if [ $? -ne 0 ]; then
        echo "❌ FAIL: License files check failed with valid files" >&2
        cd "$initial_dir" && rm -rf "$test_dir"
        return 1
    fi
    echo "✅ PASS: License files validation" >&2

    # Test 3: Check license header processing
    echo "🔍 Testing license header processing..." >&2
    license_check_read_small_license
    if [ -z "$LICENSE_HEADER" ]; then
        echo "❌ FAIL: Failed to read license header" >&2
        echo "ℹ️  LICENSE_HEADER content: '$LICENSE_HEADER'" >&2
        cd "$initial_dir" && rm -rf "$test_dir"
        return 1
    fi
    echo "✅ PASS: License header processing" >&2
    echo "ℹ️  License header: '$LICENSE_HEADER'" >&2

    # Test 4: Check file processing
    echo "🔍 Testing file processing..." >&2
    local test_files=(
        "test.sh"
        "script.js"
        "component.tsx"
        "module.go"
    )
    
    # Create test files with appropriate content for each type
    echo "#!/usr/bin/env bash
echo 'Sample bash content'" > test.sh
    echo "// JavaScript module
function hello() {
    console.log('Hello');
}" > script.js
    echo "import React from 'react';
const Component = () => {
    return <div>Hello</div>;
};" > component.tsx
    echo "package main
import \"fmt\"
func main() {
    fmt.Println(\"Hello\")
}" > module.go

    for file in "${test_files[@]}"; do
        echo "Created test file: $file" >&2
    done

    # Run the processing
    echo "🔄 Processing files..." >&2
    license_check_process_all_files

    # Verify results
    local all_ok=true
    for file in "${test_files[@]}"; do
        if ! grep -q "$LICENSE_HEADER" "$file"; then
            echo "❌ FAIL: License header not added to $file" >&2
            echo "ℹ️  File content:" >&2
            cat "$file" >&2
            all_ok=false
        else
            echo "✅ PASS: $file has license header" >&2
        fi
        
        # Verify empty line separator exists
        case "$file" in
            test.sh)
                # Shebang files should have empty line at position 3
                local third_line=$(sed -n '3p' "$file")
                if [[ -z "$third_line" ]]; then
                    echo "✅ PASS: $file has empty line separator" >&2
                else
                    echo "❌ FAIL: $file missing empty line separator" >&2
                    echo "ℹ️  Third line: '$third_line'" >&2
                    all_ok=false
                fi
                ;;
            *)
                # Non-shebang files should have empty line at position 2
                local second_line=$(sed -n '2p' "$file")
                if [[ -z "$second_line" ]]; then
                    echo "✅ PASS: $file has empty line separator" >&2
                else
                    echo "❌ FAIL: $file missing empty line separator" >&2
                    echo "ℹ️  Second line: '$second_line'" >&2
                    all_ok=false
                fi
                ;;
        esac
    done

    if [ "$all_ok" = false ]; then
        cd "$initial_dir" && rm -rf "$test_dir"
        return 1
    fi

    # Cleanup
    echo "🧹 Cleaning up test environment..." >&2
    cd "$initial_dir" && rm -rf "$test_dir"
    echo "🎉 All license_check tests passed successfully!" >&2
    return 0
}