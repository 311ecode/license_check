#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

license_check_remove_existing_headers() {
    local file="$1"
    
    # Create a temporary file to store cleaned content
    local temp_file=$(mktemp)
    local shebang_line=""
    local license_block_found=false
    local in_license_block=false
    local content_started=false
    
    [[ "$DEBUG" ]] && echo "🐛 DEBUG: Starting header removal for $file" >&2
    
    # First pass: extract shebang if present
    local first_line=$(head -n 1 "$file" 2>/dev/null)
    if [[ "$first_line" == "#!/"* ]]; then
        shebang_line="$first_line"
        echo "$shebang_line" >> "$temp_file"
        [[ "$DEBUG" ]] && echo "🐛 DEBUG: Preserved shebang: $shebang_line" >&2
    fi
    
    # Second pass: process the rest of the file
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$DEBUG" ]] && echo "🐛 DEBUG: Processing line: '$line'" >&2
        
        # Skip shebang line if we already processed it
        if [[ "$line" == "#!/"* ]] && [[ -n "$shebang_line" ]]; then
            [[ "$DEBUG" ]] && echo "🐛 DEBUG: Skipping shebang line" >&2
            continue
        fi
        
        # Check if this line is part of a license header block
        if [[ "$line" =~ ^[[:space:]]*#.*[Cc]opyright ]] || \
           [[ "$line" =~ ^[[:space:]]*//.*[Cc]opyright ]] || \
           [[ "$line" =~ ^[[:space:]]*#.*[Ll]icense ]] || \
           [[ "$line" =~ ^[[:space:]]*//.*[Ll]icense ]] || \
           [[ "$line" =~ ^[[:space:]]*#.*[Pp]roprietary ]] || \
           [[ "$line" =~ ^[[:space:]]*//.*[Pp]roprietary ]] || \
           [[ "$line" =~ ^[[:space:]]*#.*©.*[0-9]{4} ]] || \
           [[ "$line" =~ ^[[:space:]]*//.*©.*[0-9]{4} ]] || \
           [[ "$line" =~ ^[[:space:]]*#.*[Cc]ontact: ]] || \
           [[ "$line" =~ ^[[:space:]]*//.*[Cc]ontact: ]] || \
           [[ "$line" =~ ^[[:space:]]*#.*This\ is\ proprietary ]] || \
           [[ "$line" =~ ^[[:space:]]*//.*This\ is\ proprietary ]]; then
            # Found license header - mark block as found and skip this line
            license_block_found=true
            in_license_block=true
            [[ "$DEBUG" ]] && echo "🐛 DEBUG: Found license header line, skipping: '$line'" >&2
            continue
        fi
        
        # If we're in a license block, check if this line continues the block
        if [[ "$in_license_block" == true ]]; then
            # If it's an empty line right after license, skip it too
            if [[ -z "$line" ]]; then
                [[ "$DEBUG" ]] && echo "🐛 DEBUG: Skipping empty line after license header" >&2
                in_license_block=false
                continue
            fi
            
            # If it's another comment line that could be part of the license block, skip it
            if [[ "$line" =~ ^[[:space:]]*# ]] || [[ "$line" =~ ^[[:space:]]*// ]]; then
                [[ "$DEBUG" ]] && echo "🐛 DEBUG: Skipping potential license continuation line: '$line'" >&2
                continue
            fi
            
            # If we hit non-comment content, we're done with license section
            in_license_block=false
            [[ "$DEBUG" ]] && echo "🐛 DEBUG: End of license block detected" >&2
        fi
        
        # If we're no longer in license block, preserve all content
        if [[ "$in_license_block" == false ]]; then
            # Skip leading empty lines if no content has started yet
            if [[ -z "$line" ]] && [[ "$content_started" == false ]]; then
                [[ "$DEBUG" ]] && echo "🐛 DEBUG: Skipping leading empty line" >&2
                continue
            fi
            
            # Mark that content has started
            if [[ -n "$line" ]]; then
                content_started=true
                [[ "$DEBUG" ]] && echo "🐛 DEBUG: Content started, preserving line: '$line'" >&2
            fi
            
            # Preserve this line and the rest of the file
            echo "$line" >> "$temp_file"
            if [[ -n "$line" ]]; then
                # Copy the rest of the file efficiently
                cat >> "$temp_file"
                break
            fi
        fi
    done < "$file"
    
    # Replace original file with cleaned version
    mv "$temp_file" "$file"
    
    if [[ "$DEBUG" ]]; then
        echo "🐛 DEBUG: Header removal complete for $file" >&2
        echo "🐛 DEBUG: File content after header removal:" >&2
        cat -n "$file" >&2
        echo "---" >&2
    fi
}