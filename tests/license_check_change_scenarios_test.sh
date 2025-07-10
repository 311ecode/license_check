#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

testLicenseCheckChangeScenarios() {
    local initial_dir=$(pwd)
    trap 'cd "$initial_dir"' EXIT

    # Setup
    echo "🛠️  Setting up test environment for license change scenarios..." >&2
    local test_dir=$(mktemp -d -t license-change-scenarios-XXXXXXXXXX)
    cd "$test_dir" || return 1
    echo "📁 Test directory: $test_dir" >&2

    # Initialize test repo and license files
    git init
    echo "Full license text" > LICENSE
    
    # Test multiple license changes in sequence
    local licenses=(
        "Copyright © 2024 Company A - MIT License"
        "Copyright © 2025 Company B - Apache License 2.0"
        "Copyright © 2025 Company C - Proprietary Software"
        "© 2025 Final Company - All Rights Reserved"
    )

    # Create test file with existing manual license
    local test_file="complex_test.sh"
    echo "#!/usr/bin/env bash
# Copyright © 2023 Old Company - GPL License
# This is proprietary software
# Contact: old@company.com
echo 'Hello World'
function test_function() {
    echo 'This is a test'
    # Another comment
    return 0
}" > "$test_file"

    echo "🐛 DEBUG: Created test file with existing manual license:" >&2
    cat -n "$test_file" >&2
    echo "---" >&2

    # Store original functional content (excluding existing headers)
    local expected_functional_content="echo 'Hello World'
function test_function() {
    echo 'This is a test'
    # Another comment
    return 0
}"

    local all_ok=true

    # Test each license change
    for i in "${!licenses[@]}"; do
        local license="${licenses[$i]}"
        local iteration=$((i + 1))
        
        echo "🔄 Testing license change iteration $iteration: '$license'" >&2
        
        # Update license file
        echo "$license" > license.small
        
        # Apply license
        license_check_read_small_license
        license_check_add_header "$test_file"
        
        echo "🐛 DEBUG: After iteration $iteration:" >&2
        cat -n "$test_file" >&2
        echo "---" >&2
        
        # Verify current license is present
        if ! grep -q "$license" "$test_file"; then
            echo "❌ FAIL: Current license '$license' not found in iteration $iteration" >&2
            all_ok=false
        else
            echo "✅ PASS: Current license found in iteration $iteration" >&2
        fi
        
        # Verify previous licenses are removed
        for j in "${!licenses[@]}"; do
            if [ $j -lt $i ]; then
                local prev_license="${licenses[$j]}"
                if grep -q "$prev_license" "$test_file"; then
                    echo "❌ FAIL: Previous license '$prev_license' still present in iteration $iteration" >&2
                    all_ok=false
                else
                    echo "✅ PASS: Previous license '$prev_license' removed in iteration $iteration" >&2
                fi
            fi
        done
        
        # Verify old manual license is removed
        if grep -q "Copyright © 2023 Old Company" "$test_file"; then
            echo "❌ FAIL: Old manual license still present in iteration $iteration" >&2
            all_ok=false
        else
            echo "✅ PASS: Old manual license removed in iteration $iteration" >&2
        fi
        
        # Verify exactly one current license header
        local current_header_count=$(grep -c "$license" "$test_file")
        if [ "$current_header_count" -eq 1 ]; then
            echo "✅ PASS: Exactly one current license header in iteration $iteration" >&2
        else
            echo "❌ FAIL: Expected 1 current license header in iteration $iteration, found $current_header_count" >&2
            all_ok=false
        fi
        
        # Verify shebang is preserved and first
        local first_line=$(head -n 1 "$test_file")
        if [[ "$first_line" == "#!/usr/bin/env bash" ]]; then
            echo "✅ PASS: Shebang preserved as first line in iteration $iteration" >&2
        else
            echo "❌ FAIL: Shebang not preserved in iteration $iteration. First line: '$first_line'" >&2
            all_ok=false
        fi
        
        # Verify empty line separator exists
        local third_line=$(sed -n '3p' "$test_file")
        if [[ -z "$third_line" ]]; then
            echo "✅ PASS: Empty line separator present in iteration $iteration" >&2
        else
            echo "❌ FAIL: Missing empty line separator in iteration $iteration" >&2
            echo "🐛 DEBUG: Third line is: '$third_line'" >&2
            all_ok=false
        fi
        
        # Verify functional content is preserved (starts from line 4 with new format)
        local functional_content=$(tail -n +4 "$test_file")
        if [[ "$functional_content" == "$expected_functional_content" ]]; then
            echo "✅ PASS: Functional content preserved in iteration $iteration" >&2
        else
            echo "❌ FAIL: Functional content not preserved in iteration $iteration" >&2
            echo "🐛 DEBUG: Expected functional content:" >&2
            echo "$expected_functional_content" >&2
            echo "🐛 DEBUG: Actual functional content:" >&2
            echo "$functional_content" >&2
            all_ok=false
        fi
    done

    # Test rapid license changes (stress test)
    echo "🔄 Testing rapid license changes..." >&2
    for rapid_i in {1..10}; do
        echo "Rapid License Change #$rapid_i" > license.small
        license_check_read_small_license
        license_check_add_header "$test_file"
    done

    # Verify final state after rapid changes
    local final_header_count=$(grep -c "Rapid License Change #10" "$test_file")
    if [ "$final_header_count" -eq 1 ]; then
        echo "✅ PASS: Rapid license changes handled correctly" >&2
    else
        echo "❌ FAIL: Rapid license changes failed. Found $final_header_count instances of final license" >&2
        all_ok=false
    fi

    # Verify no accumulation of old rapid licenses
    local total_rapid_licenses=$(grep -c "Rapid License Change" "$test_file")
    if [ "$total_rapid_licenses" -eq 1 ]; then
        echo "✅ PASS: No accumulation of rapid license changes" >&2
    else
        echo "❌ FAIL: Found $total_rapid_licenses rapid license headers (should be 1)" >&2
        all_ok=false
    fi

    # Verify final empty line separator still exists
    local final_third_line=$(sed -n '3p' "$test_file")
    if [[ -z "$final_third_line" ]]; then
        echo "✅ PASS: Empty line separator maintained after rapid changes" >&2
    else
        echo "❌ FAIL: Empty line separator lost after rapid changes" >&2
        all_ok=false
    fi

    echo "🐛 DEBUG: Final file state after all tests:" >&2
    cat -n "$test_file" >&2

    # Cleanup
    echo "🧹 Cleaning up test environment..." >&2
    cd "$initial_dir" && rm -rf "$test_dir"
    
    if [ "$all_ok" = true ]; then
        echo "🎉 All license change scenario tests passed successfully!" >&2
        return 0
    else
        echo "💥 Some license change scenario tests failed" >&2
        return 1
    fi
}