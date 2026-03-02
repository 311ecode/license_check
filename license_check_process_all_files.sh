#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

license_check_process_all_files() {
  echo "Adding license headers from license.small file..."
  echo "License text: $LICENSE_HEADER"
  echo ""

  # Since license_check_project_root already CD-ed us to the root,
  # 'find .' safely covers the entire project tree.
  
  # Process all supported file types by extension
  find . -type f \( \
    -name "*.sh" -o \
    -name "*.bash" -o \
    -name "*.js" -o \
    -name "*.ts" -o \
    -name "*.jsx" -o \
    -name "*.tsx" -o \
    -name "*.go" -o \
    -name "*.py" \
    \) -print0 | while IFS= read -r -d '' file; do
    license_check_add_header "$file"
  done

  # Process files with bash shebang but no extension
  # Using -exec grep -l is safe here
  find . -type f ! -name "*.*" -exec grep -q "^#!/.*bash" {} \; -print0 | while IFS= read -r -d '' file; do
    license_check_add_header "$file"
  done

  echo "License headers added to all supported file types!"
}
