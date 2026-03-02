#!/usr/bin/env bash
# Copyright 2025 Imre Toth <tothimre@gmail.com> - Licensed under the Apache License, Version 2.0. See LICENSE file for terms.

license_check() {
  command -v markdown-show-help-registration &>/dev/null && eval "$(markdown-show-help-registration --minimum-parameters 0)"
  # 1. Find the root using findUp logic and CD there
  license_check_project_root
  
  # 2. Double check file presence
  license_check_license_files
  
  # 3. Read the small license into memory
  license_check_read_small_license
  
  # 4. Execute the processing from the root downwards
  license_check_process_all_files
}
