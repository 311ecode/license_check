#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

testLicenseCheckMultiFile() {
    local initial_dir=$(pwd)
    trap 'cd "$initial_dir"' EXIT

    # Setup
    echo "🛠️  Setting up test environment..." >&2
    local test_dir=$(mktemp -d -t license-multi-test-XXXXXXXXXX)
    cd "$test_dir" || return 1
    echo "📁 Test directory: $test_dir" >&2
    echo "🐛 DEBUG: Temp directory created at $test_dir" >&2

    # Initialize test repo and license files
    git init
    echo "Full license text" > LICENSE
    echo "Test Copyright Header" > license.small
    echo "🐛 DEBUG: Created license files" >&2

    # Create test files for different languages
    local test_files=(
        "script.sh"
        "module.js"
        "program.go"
        "app.py"
        "component.tsx"
        "file_without_extension"
    )

    # Create content for each file type with debug info
    echo "#!/usr/bin/env bash
echo 'Hello Bash'" > script.sh
    echo "// JavaScript content
function test() {}" > module.js
    echo "package main

func main() {}" > program.go
    echo "# Python script
print('Hello')" > app.py
    echo "import React from 'react';
const Test = () => null;" > component.tsx
    echo "#!/usr/bin/env bash
# This has shebang but no extension" > file_without_extension

    # Run the processing
    echo "🔄 Processing all file types..." >&2
    license_check_read_small_license
    echo "🐛 DEBUG: LICENSE_HEADER='$LICENSE_HEADER'" >&2
    license_check_process_all_files

    # Verify results with detailed debug output
    local all_ok=true
    for file in "${test_files[@]}"; do
        echo "🔍 Verifying $file..." >&2
        if ! grep -q "$LICENSE_HEADER" "$file"; then
            echo "❌ FAIL: License header not added to $file" >&2
            echo "🐛 DEBUG: Current file content:" >&2
            cat "$file" >&2
            all_ok=false
        else
            echo "✅ PASS: $file has license header" >&2
            
            # Verify correct comment style was used and empty line separator exists
            case "$file" in
                script.sh|file_without_extension)
                    local second_line=$(sed -n '2p' "$file")
                    local third_line=$(sed -n '3p' "$file")
                    if [[ "$second_line" =~ ^\#\ Test\ Copyright\ Header ]]; then
                        echo "✅ PASS: $file has correct comment placement after shebang" >&2
                    else
                        echo "❌ FAIL: $file has wrong comment placement" >&2
                        echo "🐛 DEBUG: Second line is: '$second_line'" >&2
                        all_ok=false
                    fi
                    if [[ -z "$third_line" ]]; then
                        echo "✅ PASS: $file has mandatory empty line after license" >&2
                    else
                        echo "❌ FAIL: $file missing mandatory empty line after license" >&2
                        echo "🐛 DEBUG: Third line is: '$third_line'" >&2
                        all_ok=false
                    fi
                    ;;
                *.js|*.tsx|*.go)
                    local first_line=$(head -n 1 "$file")
                    local second_line=$(sed -n '2p' "$file")
                    if [[ "$first_line" =~ ^\/\/\ Test\ Copyright\ Header ]]; then
                        echo "✅ PASS: $file has correct // comment style" >&2
                    else
                        echo "❌ FAIL: $file has wrong comment style" >&2
                        echo "🐛 DEBUG: First line is: '$first_line'" >&2
                        all_ok=false
                    fi
                    if [[ -z "$second_line" ]]; then
                        echo "✅ PASS: $file has mandatory empty line after license" >&2
                    else
                        echo "❌ FAIL: $file missing mandatory empty line after license" >&2
                        echo "🐛 DEBUG: Second line is: '$second_line'" >&2
                        all_ok=false
                    fi
                    ;;
                *.py)
                    local first_line=$(head -n 1 "$file")
                    local second_line=$(sed -n '2p' "$file")
                    if [[ "$first_line" =~ ^\#\ Test\ Copyright\ Header ]]; then
                        echo "✅ PASS: $file has correct # comment style" >&2
                    else
                        echo "❌ FAIL: $file has wrong comment style" >&2
                        echo "🐛 DEBUG: First line is: '$first_line'" >&2
                        all_ok=false
                    fi
                    if [[ -z "$second_line" ]]; then
                        echo "✅ PASS: $file has mandatory empty line after license" >&2
                    else
                        echo "❌ FAIL: $file missing mandatory empty line after license" >&2
                        echo "🐛 DEBUG: Second line is: '$second_line'" >&2
                        all_ok=false
                    fi
                    ;;
            esac
        fi
    done

    # Cleanup
    echo "🧹 Cleaning up test environment..." >&2
    cd "$initial_dir" && rm -rf "$test_dir"
    
    if [ "$all_ok" = true ]; then
        echo "🎉 All multi-file license_check tests passed successfully!" >&2
        return 0
    else
        echo "💥 Some multi-file tests failed" >&2
        return 1
    fi
}