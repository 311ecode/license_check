# License Check Tool

A bash script to automatically add license headers to source code files in a project.

## Usage

```bash
license_check
No parameters are required. The script will:

Check that it's being run from the project root (where .git exists)
Verify the presence of required license files (LICENSE and license.small)
Process all supported files to add license headers

For help, use:
bashlicense_check.sh -h
# or
license_check.sh --help
```

Supported File Types
The tool automatically handles these file types with appropriate comment styles:

Shell scripts (.sh, .bash)
JavaScript/TypeScript (.js, .ts, .jsx, .tsx)
Go (.go)
Python (.py)
Files with bash shebang (regardless of extension)

Requirements

Must be run from project root directory (contains .git)
These files must exist in project root:

LICENSE (full license text)
license.small (short header version)



License Header Format
The tool adds license headers with the following structure:
For files with shebang:
bash#!/usr/bin/env bash
# Copyright © 2025 Company Name - License Text

# Original file content starts here
echo "Hello World"
For files without shebang:
javascript// Copyright © 2025 Company Name - License Text

// Original file content starts here
function hello() {
    console.log("Hello World");
}
Important: The tool automatically adds a mandatory empty line after each license header to clearly separate the license from the original file content. This ensures clean formatting and reliable header detection during updates.
How It Works

Project Validation:

Checks for .git directory to confirm project root
Verifies existence of required license files


Header Processing:

Reads the license header from license.small
Processes all supported files:

Removes any existing license headers (including the separator empty line)
Adds new header in appropriate comment style
Adds mandatory empty line separator after header
Special handling for files with shebang lines




Comment Styles:

// for JavaScript/TypeScript/Go
# for Shell/Python
Automatically detects shebang lines for proper placement


Header Updates:

Running the tool multiple times is safe and will not create duplicates
Changing the license.small file and re-running will update all headers
Original file content is always preserved



Examples
Adding headers to all files:
bashlicense_check
Before:
bash#!/usr/bin/env bash
echo "Hello World"
After:
bash#!/usr/bin/env bash
# Copyright © 2025 Your Company - MIT License

echo "Hello World"
Testing
The project includes comprehensive tests:
bashlicence_check_testAll
Tests cover:

Basic functionality across multiple file types
License header overwriting and updates
Repeated execution stability
Complex license change scenarios
Empty line separator handling

Implementation Notes

The tool is implemented purely in bash for maximum compatibility
Uses find+grep for efficient file processing
Handles edge cases like files with shebang but no extension
Mandatory empty line separator ensures clean formatting and reliable parsing
Safe for repeated execution - will not accumulate headers or extra spacing