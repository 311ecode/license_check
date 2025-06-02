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
    echo "Full license text" > LICENSE
    echo "Old Copyright Header" > license.small
    echo "🐛 DEBUG: Created initial license files" >&2

    # Create test file
    local test_file="test.sh"
    echo "#!/usr/bin/env bash
echo 'Hello'" > "$test_file"
    echo "🐛 DEBUG: Created test file:" >&2
    cat "$test_file" >&2

    # Process with old license
    license_check_read_small_license
    license_check_add_header "$test_file"
    echo "🐛 DEBUG: After first processing:" >&2
    cat "$test_file" >&2

    # Change the license content
    echo "New Copyright Header" > license.small
    echo "🐛 DEBUG: Updated license.small content:" >&2
    cat license.small >&2

    # Process with new license (should remove old and add new)
    license_check_read_small_license
    license_check_add_header "$test_file"
    echo "🐛 DEBUG: After second processing:" >&2
    cat "$test_file" >&2

    # Verify results
    local all_ok=true

    # Check that old license is gone
    if grep -q "Old Copyright Header" "$test_file"; then
        echo "❌ FAIL: Old license header still present in $test_file" >&2
        all_ok=false
    else
        echo "✅ PASS: Old license header removed from $test_file" >&2
    fi

    # Check that new license is present
    if grep -q "New Copyright Header" "$test_file"; then
        echo "✅ PASS: New license header added to $test_file" >&2
    else
        echo "❌ FAIL: New license header missing from $test_file" >&2
        all_ok=false
    fi

    # Verify we only have one instance of the new header
    local header_count=$(grep -c "New Copyright Header" "$test_file")
    if [ "$header_count" -eq 1 ]; then
        echo "✅ PASS: Exactly one license header present" >&2
    else
        echo "❌ FAIL: Expected 1 license header, found $header_count in $test_file" >&2
        all_ok=false
    fi

    # Verify shebang is still intact and first
    local first_line=$(head -n 1 "$test_file")
    if [[ "$first_line" == "#!/usr/bin/env bash" ]]; then
        echo "✅ PASS: Shebang preserved as first line" >&2
    else
        echo "❌ FAIL: Shebang not preserved correctly. First line: '$first_line'" >&2
        all_ok=false
    fi

    # Cleanup
    echo "🧹 Cleaning up test environment..." >&2
    cd "$initial_dir" && rm -rf "$test_dir"
    
    if [ "$all_ok" = true ]; then
        echo "🎉 License overwrite test passed successfully!" >&2
        return 0
    else
        echo "💥 License overwrite test failed" >&2
        return 1
    fi
}
