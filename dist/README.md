# License Check Tool

A bash script to automatically add license headers to source code files in a project.

## Usage

```bash
license_check
```

No parameters are required. The script will:
1. Check that it's being run from the project root (where .git exists)
2. Verify the presence of required license files (LICENSE and license.small)
3. Process all supported files to add license headers

For help, use:
```bash
license_check.sh -h
# or
license_check.sh --help
```

## Supported File Types

The tool automatically handles these file types with appropriate comment styles:
- Shell scripts (.sh, .bash)
- JavaScript/TypeScript (.js, .ts, .jsx, .tsx)
- Go (.go)
- Python (.py)
- Files with bash shebang (regardless of extension)

## Requirements

1. Must be run from project root directory (contains .git)
2. These files must exist in project root:
   - LICENSE (full license text)
   - license.small (short header version)

## How It Works

1. **Project Validation**:
   - Checks for .git directory to confirm project root
   - Verifies existence of required license files

2. **Header Processing**:
   - Reads the license header from license.small
   - Processes all supported files:
     - Removes any existing license headers
     - Adds new header in appropriate comment style
     - Special handling for files with shebang lines

3. **Comment Styles**:
   - `//` for JavaScript/TypeScript/Go
   - `#` for Shell/Python
   - Automatically detects shebang lines for proper placement

## Examples

Adding headers to all files:
```bash
license_check
```

## Testing

The project includes comprehensive tests:
```bash
licence_check_testAll
```

Tests cover:
- Basic functionality
- Multiple file type handling
- License header overwriting

## Implementation Notes

- The tool is implemented purely in bash for maximum compatibility
- Uses find+grep for efficient file processing
- Handles edge cases like files with shebang but no extension
