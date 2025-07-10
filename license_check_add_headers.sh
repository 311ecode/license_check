#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

license_check_add_header() {
    local file="$1"
    local extension="${file##*.}"

    [[ "$DEBUG" ]] && echo "🐛 DEBUG: Processing file: $file" >&2
    [[ "$DEBUG" ]] && echo "🐛 DEBUG: File extension: $extension" >&2
    
    # Remove any existing license headers first
    license_check_remove_existing_headers "$file"

    # Check for shebang
    local first_line=$(head -n 1 "$file" 2>/dev/null)
    [[ "$DEBUG" ]] && echo "🐛 DEBUG: First line: '$first_line'" >&2
    
    # Determine if this should be treated as a shebang file based on BOTH shebang presence AND file extension
    local has_valid_shebang=false
    if [[ "$first_line" == "#!/usr/bin/env bash"* ]] || [[ "$first_line" == "#!/bin/bash"* ]]; then
        # Only treat as shebang file if it's a shell file or has no extension
        if [[ "$extension" == "sh" ]] || [[ "$extension" == "bash" ]] || [[ "$file" != *.* ]]; then
            has_valid_shebang=true
        fi
    fi
    
    if [[ "$has_valid_shebang" == true ]]; then
        [[ "$DEBUG" ]] && echo "🐛 DEBUG: File has valid shebang for shell - using shebang logic" >&2
        # For files with shebang: add license after line 1, then add empty line after license
        [[ "$DEBUG" ]] && echo "🐛 DEBUG: Adding license after line 1: '# $LICENSE_HEADER'" >&2
        sed -i "1a\\# $LICENSE_HEADER" "$file"
        
        if [[ "$DEBUG" ]]; then
            echo "🐛 DEBUG: File content AFTER adding license:" >&2
            cat -n "$file" >&2
            echo "---" >&2
        fi
        
        [[ "$DEBUG" ]] && echo "🐛 DEBUG: Adding empty line after line 2" >&2
        sed -i '2 a\\' "$file"
        
        if [[ "$DEBUG" ]]; then
            echo "🐛 DEBUG: File content AFTER adding empty line:" >&2
            cat -n "$file" >&2
            echo "---" >&2
        fi
        return
    fi

    [[ "$DEBUG" ]] && echo "🐛 DEBUG: File has no valid shebang or inappropriate shebang - using extension-based logic" >&2
    case "$extension" in
        js|ts|jsx|tsx|go)
            [[ "$DEBUG" ]] && echo "🐛 DEBUG: Using // comment style for $extension files" >&2
            # JavaScript/TypeScript/Go files: add license at top, then add empty line
            [[ "$DEBUG" ]] && echo "🐛 DEBUG: Adding license at line 1: '// $LICENSE_HEADER'" >&2
            sed -i "1i\\// $LICENSE_HEADER" "$file"
            
            if [[ "$DEBUG" ]]; then
                echo "🐛 DEBUG: File content AFTER adding license:" >&2
                cat -n "$file" >&2
                echo "---" >&2
            fi
            
            [[ "$DEBUG" ]] && echo "🐛 DEBUG: Adding empty line after line 1" >&2
            sed -i '1 a\\' "$file"
            
            if [[ "$DEBUG" ]]; then
                echo "🐛 DEBUG: File content AFTER adding empty line:" >&2
                cat -n "$file" >&2
                echo "---" >&2
            fi
            ;;
        sh|bash|py|*)
            [[ "$DEBUG" ]] && echo "🐛 DEBUG: Using # comment style for $extension files (default case)" >&2
            # Bash/shell/Python files and default case: add license at top, then add empty line
            [[ "$DEBUG" ]] && echo "🐛 DEBUG: Adding license at line 1: '# $LICENSE_HEADER'" >&2
            sed -i "1i\\# $LICENSE_HEADER" "$file"
            
            if [[ "$DEBUG" ]]; then
                echo "🐛 DEBUG: File content AFTER adding license:" >&2
                cat -n "$file" >&2
                echo "---" >&2
            fi
            
            [[ "$DEBUG" ]] && echo "🐛 DEBUG: Adding empty line after line 1" >&2
            sed -i '1 a\\' "$file"
            
            if [[ "$DEBUG" ]]; then
                echo "🐛 DEBUG: File content AFTER adding empty line:" >&2
                cat -n "$file" >&2
                echo "---" >&2
            fi
            ;;
    esac
    
    if [[ "$DEBUG" ]]; then
        echo "🐛 DEBUG: Final file content:" >&2
        cat -n "$file" >&2
        echo "=== END DEBUG FOR $file ===" >&2
    fi
}