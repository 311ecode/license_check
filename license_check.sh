#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.
license_check() {
  license_check_project_root
  license_check_license_files
  license_check_read_small_license
  license_check_process_all_files
}
