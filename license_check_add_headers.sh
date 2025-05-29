#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.
license_check_add_header() {
    local file="$1"
    local extension="${file##*.}"

    # Remove any existing license headers first
    license_check_remove_existing_headers "$file"

    # Special case for files with bash shebang
    local first_line=$(head -n 1 "$file" 2>/dev/null)
    if [[ "$first_line" == "#!/usr/bin/env bash"* ]] || [[ "$first_line" == "#!/bin/bash"* ]]; then
        # For files with shebang, insert after first line
        sed -i "1a\# $LICENSE_HEADER" "$file"
        return
    fi

    case "$extension" in
        js|ts|jsx|tsx|go)
            # JavaScript/TypeScript/Go files
            sed -i "1i\// $LICENSE_HEADER" "$file"
            ;;
        sh|bash|py|*)
            # Bash/shell/Python files and default case
            sed -i "1i\# $LICENSE_HEADER" "$file"
            ;;
    esac
}