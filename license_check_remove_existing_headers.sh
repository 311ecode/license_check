#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

license_check_remove_existing_headers() {
  local file="$1"
  local temp_file=$(mktemp)
  local shebang_line=""
  local in_license_block=false
  local content_started=false

  # Step 1: Extract Shebang (Migration Safety)
  local first_line=$(head -n 1 "$file" 2>/dev/null)
  if [[ $first_line == "#!/"* ]]; then
    shebang_line="$first_line"
    echo "$shebang_line" >>"$temp_file"
  fi

  # Step 2: Strip old blocks
  while IFS= read -r line || [[ -n $line ]]; do
    # Skip shebang if we handled it
    if [[ $line == "#!/"* ]] && [[ -n $shebang_line ]]; then
      continue
    fi

    # Migration Detection: Match old license patterns
    if [[ $line =~ ^[[:space:]]*#.*[Cc]opyright ]] ||
       [[ $line =~ ^[[:space:]]*//.*[Cc]opyright ]] ||
       [[ $line =~ ^[[:space:]]*#.*[Ll]icense ]] ||
       [[ $line =~ ^[[:space:]]*//.*[Ll]icense ]] ||
       [[ $line =~ ^[[:space:]]*#.*©.*[0-9]{4} ]]; then
      in_license_block=true
      continue
    fi

    if [[ $in_license_block == true ]]; then
      # Skip the mandatory empty line that followed the OLD license
      if [[ -z $line ]]; then
        in_license_block=false
        continue
      fi
      # If it's a comment continuation, keep skipping
      if [[ $line =~ ^[[:space:]]*# ]] || [[ $line =~ ^[[:space:]]*// ]]; then
        continue
      fi
      in_license_block=false
    fi

    # Step 3: Preserve the actual source code
    if [[ $in_license_block == false ]]; then
      if [[ -z $line ]] && [[ $content_started == false ]]; then
        continue
      fi
      if [[ -n $line ]]; then
        content_started=true
      fi
      echo "$line" >>"$temp_file"
      # Stream the rest for performance
      cat >>"$temp_file"
      break
    fi
  done <"$file"

  mv "$temp_file" "$file"
}
