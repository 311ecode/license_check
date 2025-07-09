#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

license_check_remove_existing_headers() {
    local file="$1"
    
    # Create a temporary file to store cleaned content
    local temp_file=$(mktemp)
    local shebang_line=""
    local content_started=false
    local skip_empty_lines=true
    
    # First pass: extract shebang if present
    local first_line=$(head -n 1 "$file" 2>/dev/null)
    if [[ "$first_line" == "#!/"* ]]; then
        shebang_line="$first_line"
        echo "$shebang_line" >> "$temp_file"
    fi
    
    # Second pass: process the rest of the file
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip shebang line if we already processed it
        if [[ "$line" == "#!/"* ]] && [[ -n "$shebang_line" ]]; then
            continue
        fi
        
        # Check if this line looks like a license header
        if [[ "$line" =~ ^[[:space:]]*#.*[Cc]opyright ]] || \
           [[ "$line" =~ ^[[:space:]]*//.*[Cc]opyright ]] || \
           [[ "$line" =~ ^[[:space:]]*#.*[Ll]icense ]] || \
           [[ "$line" =~ ^[[:space:]]*//.*[Ll]icense ]] || \
           [[ "$line" =~ ^[[:space:]]*#.*[Pp]roprietary ]] || \
           [[ "$line" =~ ^[[:space:]]*//.*[Pp]roprietary ]]; then
            # Skip license header lines
            continue
        fi
        
        # Handle empty lines - skip them until we find actual content
        if [[ -z "$line" ]]; then
            if [[ "$content_started" == true ]]; then
                # Content has started, preserve empty lines
                echo "$line" >> "$temp_file"
            fi
            # If content hasn't started, skip empty lines to avoid accumulation
            continue
        fi
        
        # This is actual content (not header, not empty)
        content_started=true
        skip_empty_lines=false
        echo "$line" >> "$temp_file"
        
        # Copy the rest of the file efficiently
        cat >> "$temp_file"
        break
    done < "$file"
    
    # Replace original file with cleaned version
    mv "$temp_file" "$file"
}