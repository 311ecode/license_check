#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

licence_check_testAll() {
  # Fix for localization issue with decimal points
  export LC_NUMERIC=C

  # Define test functions (ensuring all are present in the environment)
  local test_suites=(
    "testLicenseCheckFindUp"
    "testLicenseCheckMultiFile"
    "testLicenseCheck"
    "testLicenseCheckOverwrite"
    "testLicenseCheckRepeatedExecution"
    "testLicenseCheckChangeScenarios"
    "testLicenseCheckEmptyLine"
  )

  local ignored_suites=(
    # None of the test suites are ignored by default
  )

  # Run bashTestRunner to execute all test suites
  # Note: Ensure the files containing these functions are in the same 
  # directory so the runner can locate them.
  bashTestRunner test_suites ignored_suites
  return $?
}
