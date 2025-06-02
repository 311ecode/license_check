#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.
license_check_process_all_files() {
    echo "Adding license headers from license.small file..."
    echo "License text: $LICENSE_HEADER"
    echo ""
    
    # Process all supported file types
    find . -type f \( \
        -name "*.sh" -o \
        -name "*.bash" -o \
        -name "*.js" -o \
        -name "*.ts" -o \
        -name "*.jsx" -o \
        -name "*.tsx" -o \
        -name "*.go" -o \
        -name "*.py" \
    \) | while read file; do
        license_check_add_header "$file"
    done

    # Process files with bash shebang but no extension
    find . -type f -exec grep -l "^#!/.*bash" {} \; | while read file; do
        license_check_add_header "$file"
    done

    echo "License headers added to all supported file types!"
}
