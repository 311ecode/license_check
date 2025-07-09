#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

license_check_add_bash_header() {
    local file="$1"
    
    # Check if file has shebang
    local first_line=$(head -n 1 "$file" 2>/dev/null)
    if [[ "$first_line" == "#!/usr/bin/env bash"* ]] || [[ "$first_line" == "#!/bin/bash"* ]]; then
        # For files with shebang, insert after first line
        sed -i "1a\\# $LICENSE_HEADER" "$file"
    else
        # For files without shebang, insert at beginning
        sed -i "1i\\# $LICENSE_HEADER" "$file"
    fi
}