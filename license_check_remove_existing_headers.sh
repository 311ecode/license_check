#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.
license_check_remove_existing_headers() {
    local file="$1"
    
    # Create a temporary file to store cleaned content
    local temp_file=$(mktemp)
    local in_header=false
    local shebang_preserved=false
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Preserve shebang line
        if [[ "$line" == "#!/"* ]] && [[ "$shebang_preserved" == false ]]; then
            echo "$line" >> "$temp_file"
            shebang_preserved=true
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
        
        # If we hit a non-comment line or empty line after potential headers, we're done with header section
        if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ ! "$line" =~ ^[[:space:]]*// ]] && [[ -n "$line" ]]; then
            echo "$line" >> "$temp_file"
            # Copy the rest of the file
            cat >> "$temp_file"
            break
        elif [[ -z "$line" ]]; then
            # Empty line - could be end of header section
            echo "$line" >> "$temp_file"
        else
            # Non-license comment line
            echo "$line" >> "$temp_file"
        fi
    done < "$file"
    
    # Replace original file with cleaned version
    mv "$temp_file" "$file"
}